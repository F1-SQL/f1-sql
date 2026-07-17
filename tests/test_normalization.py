import json
from dataclasses import replace
from datetime import UTC, datetime
from decimal import Decimal
from pathlib import Path

from f1sql.normalization import (
    DiscrepancySeverity,
    IdentityAmbiguity,
    IdentityResolver,
    NormalizationBundle,
    NormalizedLap,
    NormalizedPitStop,
    NormalizedRaceControl,
    NormalizedSession,
    NormalizedStint,
    NormalizedWeather,
    SourcePolicy,
    duration_ms,
    normalize_race,
    normalize_result,
    parse_utc,
    reconcile_result_sets,
    reconcile_scalar,
    reconcile_schedule_and_participants,
)
from f1sql.sources.jolpica_models import Circuit, RaceSummary, Result


def _result() -> Result:
    from f1sql.sources.jolpica_models import Constructor, Driver

    return Result(
        season=2024,
        round=1,
        number=1,
        position=1,
        position_text="1",
        points=25.0,
        driver=Driver("max", "Max", "Verstappen", "Dutch", 33),
        constructor=Constructor("red_bull", "Red Bull", "Austrian"),
        grid=1,
        laps=57,
        status="Finished",
        time="1:31:44.742",
        fastest_lap=None,
    )


def test_time_and_duration_normalization() -> None:
    assert parse_utc("2024-03-02T15:00:00Z") == datetime(2024, 3, 2, 15, tzinfo=UTC)
    assert parse_utc("2024-03-02T15:00:00", assume_utc=True) == datetime(2024, 3, 2, 15, tzinfo=UTC)
    assert duration_ms("1:31:44.742") == 5_504_742
    assert duration_ms("1:36.236") == 96_236
    assert duration_ms("+22.457") == 22_457
    assert duration_ms("+1 Lap") is None
    result, _ = normalize_result(
        replace(_result(), time="+22.457", time_millis=5_526_199), IdentityResolver()
    )
    assert result.duration_ms == 5_526_199


def test_normalized_records_are_deterministic_and_retain_ids() -> None:
    resolver = IdentityResolver()
    race = RaceSummary(
        season=2024,
        round=1,
        race_name="Bahrain Grand Prix",
        circuit=Circuit(
            "bahrain", "Bahrain International Circuit", "Sakhir", "Bahrain", None, None
        ),
        scheduled_at_utc=datetime(2024, 3, 2, 15, tzinfo=UTC),
        url=None,
        has_sprint=True,
    )
    meeting = normalize_race(race, resolver)
    result, discrepancies = normalize_result(_result(), resolver)
    bundle = NormalizationBundle(
        meetings=(meeting,), results=(result,), discrepancies=discrepancies
    )
    assert result.driver_number == 1
    assert result.duration_ms == 5_504_742
    assert result.external_ids["jolpica:driver"] == "max"
    assert bundle.fingerprint() == bundle.fingerprint()
    assert '"round":1' in bundle.to_json()


def test_source_policy_and_reconciliation_emit_evidence() -> None:
    policy = SourcePolicy()
    source, value = policy.primary("result", {"fastf1": 1, "jolpica": 2})
    assert (source, value) == ("jolpica", 2)
    selected, discrepancies = reconcile_scalar(
        "result", "points", {"jolpica": "25.0", "fastf1": "25.01"}, Decimal("0.001"), "jolpica"
    )
    assert selected == "25.0"
    assert discrepancies[0].severity is DiscrepancySeverity.WARNING


def test_in_scope_session_fact_models_serialize() -> None:
    timestamp = datetime(2024, 3, 2, 15, tzinfo=UTC)
    bundle = NormalizationBundle(
        sessions=(NormalizedSession(2024, 1, "race", timestamp, None, {"fastf1": "race-1"}),),
        laps=(
            NormalizedLap(
                2024,
                1,
                "race",
                "driver:max",
                1,
                100123,
                (30000, 35000, 35123),
                {"SpeedFL": Decimal("320.0")},
                {"fastf1:lap": "1"},
            ),
        ),
        stints=(NormalizedStint(2024, 1, "race", "driver:max", 1, "SOFT", 1, 10, True),),
        pit_stops=(NormalizedPitStop(2024, 1, "race", "driver:max", 1, 14, 22456, {}),),
        weather=(NormalizedWeather(2024, 1, "race", timestamp, {"AirTemp": Decimal("25.0")}),),
        race_control=(
            NormalizedRaceControl(2024, 1, "race", timestamp, "GREEN", "flag", {"fastf1": "1"}),
        ),
    )
    serialized = bundle.to_json()
    assert '"laps"' in serialized
    assert bundle.fingerprint() == bundle.fingerprint()


def test_normalization_fixture_and_identity_failure() -> None:
    fixture = Path(__file__).parent / "fixtures" / "normalization-v1" / "result.json"
    result = Result.from_api(json.loads(fixture.read_text(encoding="utf-8")))
    normalized, discrepancies = normalize_result(result, IdentityResolver())
    assert normalized.external_ids["jolpica:constructor"] == "red_bull"
    assert discrepancies == ()
    resolver = IdentityResolver()
    resolver.resolve("driver", "jolpica", "max", "Verstappen")
    try:
        resolver.resolve("driver", "jolpica", "max", "Hamilton")
    except IdentityAmbiguity:
        pass
    else:
        raise AssertionError("changed source identity was accepted")


def test_result_reconciliation_reports_winner_and_lap_conflicts() -> None:
    primary = _result()
    normalized, _ = normalize_result(primary, IdentityResolver())
    secondary = replace(normalized, position=2, laps=56)
    selected, discrepancies = reconcile_result_sets((normalized,), (secondary,))
    assert selected == (normalized,)
    assert any(
        item.field == "winner" and item.severity is DiscrepancySeverity.ERROR
        for item in discrepancies
    )
    assert any(item.field == "laps" for item in discrepancies)


def test_schedule_and_participant_reconciliation_reports_missing_coverage() -> None:
    resolver = IdentityResolver()
    race = RaceSummary(
        2024,
        1,
        "Bahrain",
        Circuit("bahrain", "Bahrain", "Sakhir", "Bahrain", None, None),
        datetime(2024, 3, 2, 15, tzinfo=UTC),
        None,
        False,
    )
    meeting = normalize_race(race, resolver)
    result, _ = normalize_result(_result(), resolver)
    _, discrepancies = reconcile_schedule_and_participants(
        (meeting,), (), (result,), ()
    )
    assert any(item.domain == "meeting" for item in discrepancies)
    assert any(item.domain == "participant" for item in discrepancies)
