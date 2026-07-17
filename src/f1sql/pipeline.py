"""Offline end-to-end pipeline assembly used by fixtures and CI acceptance tests."""

from collections.abc import Mapping
from dataclasses import dataclass, replace
from decimal import Decimal
from pathlib import Path
from typing import Any

from .cache import ArtifactStore
from .contracts import BuildTarget
from .fingerprint import canonical_json
from .load_plan import LoadPlan, build_load_plan
from .normalization import (
    Discrepancy,
    IdentityResolver,
    NormalizationBundle,
    NormalizedCircuit,
    NormalizedConstructor,
    NormalizedDriver,
    NormalizedLap,
    NormalizedPitStop,
    NormalizedRaceControl,
    NormalizedResult,
    NormalizedSession,
    NormalizedStint,
    NormalizedWeather,
    duration_ms,
    normalize_race,
    normalize_result,
    parse_utc,
    reconcile_result_sets,
)
from .quality import CoverageExpectation, CoverageGap, QualityReport, validate_bundle
from .readiness import source_fingerprint
from .release import ReleasePackager, ReleasePlan
from .sources.fastf1 import SessionSnapshot
from .sources.jolpica_models import RaceSummary, Result


class PipelineGateError(RuntimeError):
    """Raised when an offline pipeline stage cannot pass its quality gate."""


@dataclass(frozen=True, slots=True)
class OfflinePipelineResult:
    bundle: NormalizationBundle
    quality: QualityReport
    load_plan: LoadPlan
    release: ReleasePlan


def normalize_fixture(
    race: RaceSummary,
    results: tuple[Result, ...],
    session: SessionSnapshot,
    session_type: str = "race",
) -> NormalizationBundle:
    """Convert representative Jolpica and FastF1 records into v2 models."""

    resolver = IdentityResolver()
    meeting = normalize_race(race, resolver)
    circuit_key = meeting.circuit_key
    circuit = NormalizedCircuit(
        key=circuit_key,
        name=race.circuit.name,
        locality=race.circuit.locality,
        country=race.circuit.country,
        latitude=race.circuit.lat,
        longitude=race.circuit.long,
        external_ids={"jolpica:circuit": race.circuit.circuit_id},
    )
    normalized_results: list[NormalizedResult] = []
    discrepancies: list[Discrepancy] = []
    drivers: dict[str, NormalizedDriver] = {}
    constructors: dict[str, NormalizedConstructor] = {}
    driver_keys_by_number: dict[str, str] = {}
    for result in results:
        normalized, result_discrepancies = normalize_result(result, resolver, session_type)
        normalized_results.append(normalized)
        discrepancies.extend(result_discrepancies)
        if result.number is not None:
            driver_keys_by_number[str(result.number)] = normalized.driver_key
        drivers[normalized.driver_key] = NormalizedDriver(
            normalized.driver_key,
            result.driver.given_name,
            result.driver.family_name,
            {"jolpica:driver": result.driver.driver_id},
            {},
        )
        constructors[normalized.constructor_key] = NormalizedConstructor(
            normalized.constructor_key,
            result.constructor.name,
            {"jolpica:constructor": result.constructor.constructor_id},
            {},
        )

    session_model = NormalizedSession(
        race.season,
        race.round,
        session_type,
        race.scheduled_at_utc,
        None,
        {"fastf1:session": session.identifier},
    )
    records = session.records
    laps = tuple(
        _normalize_lap(race, session_type, row, driver_keys_by_number)
        for row in records.get("laps", ())
    )
    stints = tuple(
        _normalize_stint(race, session_type, row, driver_keys_by_number)
        for row in records.get("stints", ())
    )
    pit_stops = tuple(
        _normalize_pit_stop(race, session_type, row, driver_keys_by_number)
        for row in records.get("pit_stops", ())
    )
    weather = tuple(
        _normalize_weather(race, session_type, row) for row in records.get("weather", ())
    )
    race_control = tuple(
        NormalizedRaceControl(
            race.season,
            race.round,
            session_type,
            None,
            str(row.get("Message", "")),
            None,
            {},
        )
        for row in records.get("race_control", ())
        if row.get("Message")
    )
    return NormalizationBundle(
        drivers=tuple(sorted(drivers.values(), key=lambda item: item.key)),
        constructors=tuple(sorted(constructors.values(), key=lambda item: item.key)),
        circuits=(circuit,),
        meetings=(meeting,),
        sessions=(session_model,),
        results=tuple(normalized_results),
        laps=laps,
        stints=stints,
        pit_stops=pit_stops,
        weather=weather,
        race_control=race_control,
        discrepancies=tuple(discrepancies),
    )


def reconcile_fixture_sources(
    bundle: NormalizationBundle, session: SessionSnapshot
) -> tuple[Discrepancy, ...]:
    """Reconcile FastF1 session results against normalized Jolpica results."""

    normalized_by_number = {
        str(item.driver_number): item
        for item in bundle.results
        if item.driver_number is not None
    }
    secondary = []
    for row in session.records.get("results", ()):
        primary = normalized_by_number.get(str(row.get("DriverNumber")))
        if primary is None:
            continue
        secondary.append(
            replace(
                primary,
                position=int(row["Position"]) if row.get("Position") is not None else None,
                points=Decimal(str(row.get("Points", primary.points))),
            )
        )
    _, discrepancies = reconcile_result_sets(bundle.results, tuple(secondary))
    return discrepancies


def run_offline_fixture_pipeline(
    *,
    target: BuildTarget,
    race: RaceSummary,
    results: tuple[Result, ...],
    session: SessionSnapshot,
    output_root: Path,
    documents: Mapping[str, bytes],
    metadata: Mapping[str, object],
    database_backup: Path | None = None,
    raw_artifacts: Mapping[str, bytes] | None = None,
    coverage_gaps: tuple[CoverageGap, ...] = (),
    dry_run: bool = False,
) -> OfflinePipelineResult:
    """Run all offline stages and package only after the quality gate passes."""

    bundle = normalize_fixture(race, results, session)
    bundle = replace(
        bundle,
        discrepancies=bundle.discrepancies + reconcile_fixture_sources(bundle, session),
    )
    load_plan = build_load_plan(bundle)
    session_key = (race.season, race.round, "race")
    expectations = [
        CoverageExpectation("meeting", (race.season, race.round), "jolpica"),
        CoverageExpectation("session", session_key, "fastf1"),
        CoverageExpectation("participant", session_key, "jolpica"),
        CoverageExpectation("result", session_key, "jolpica"),
    ]
    for domain in ("lap", "stint", "pit_stop", "weather", "race_control"):
        expectations.append(
            CoverageExpectation(
                domain,
                session_key,
                "fastf1",
                allow_gap=domain in session.missing,
                reason=f"FastF1 did not provide {domain} for this session",
            )
        )
    quality = validate_bundle(
        bundle,
        coverage_gaps=coverage_gaps,
        coverage_expectations=tuple(expectations),
        load_plan=load_plan,
    )
    if not quality.passed:
        raise PipelineGateError("quality gate failed; release packaging was not attempted")
    assets: dict[str, bytes] = {
        **documents,
        "quality-report.json": (quality.to_json() + "\n").encode("utf-8"),
        "normalized.json": (bundle.to_json() + "\n").encode("utf-8"),
        "load-plan.json": (load_plan.to_json() + "\n").encode("utf-8"),
    }
    for name, content in (raw_artifacts or {}).items():
        assets[f"raw/{name}"] = content
    if database_backup is not None:
        assets["database.bak"] = database_backup.read_bytes()
    release_metadata = {
        **metadata,
        "source_fingerprint": source_fingerprint(race),
        "normalized_fingerprint": bundle.fingerprint(),
        "load_plan_fingerprint": load_plan.fingerprint(),
    }
    release = ReleasePackager(output_root).build(
        target, assets, release_metadata, dry_run=dry_run
    )
    return OfflinePipelineResult(bundle, quality, load_plan, release)


def persist_fastf1_snapshot(snapshot: SessionSnapshot, store: ArtifactStore) -> str:
    """Persist a FastF1 session snapshot as canonical JSON and return its digest."""

    content = canonical_json(
        {
            "season": snapshot.season,
            "round": snapshot.round,
            "identifier": snapshot.identifier,
            "source_version": snapshot.source_version,
            "status": snapshot.status,
            "coverage": snapshot.coverage,
            "records": snapshot.records,
        }
    ).encode("utf-8")
    return store.put(content).digest


def _driver_key(row: Mapping[str, Any], driver_keys_by_number: Mapping[str, str]) -> str:
    number = row.get("DriverNumber", row.get("Driver"))
    return driver_keys_by_number.get(str(number), f"driver:{number or 'unknown'}")


def _normalize_lap(
    race: RaceSummary,
    session_type: str,
    row: Mapping[str, Any],
    driver_keys_by_number: Mapping[str, str],
) -> NormalizedLap:
    return NormalizedLap(
        race.season,
        race.round,
        session_type,
        _driver_key(row, driver_keys_by_number),
        int(row["LapNumber"]),
        duration_ms(row.get("LapTime")),
        (
            duration_ms(row.get("Sector1Time")),
            duration_ms(row.get("Sector2Time")),
            duration_ms(row.get("Sector3Time")),
        ),
        {
            key: Decimal(str(row[key]))
            for key in ("SpeedI1", "SpeedI2", "SpeedFL", "SpeedST")
            if row.get(key) is not None
        },
        {},
    )


def _normalize_stint(
    race: RaceSummary,
    session_type: str,
    row: Mapping[str, Any],
    driver_keys_by_number: Mapping[str, str],
) -> NormalizedStint:
    return NormalizedStint(
        race.season,
        race.round,
        session_type,
        _driver_key(row, driver_keys_by_number),
        int(row["Stint"]),
        str(row["Compound"]) if row.get("Compound") is not None else None,
        int(row["StartLap"]) if row.get("StartLap") is not None else None,
        int(row["EndLap"]) if row.get("EndLap") is not None else None,
        bool(row["FreshTyre"]) if row.get("FreshTyre") is not None else None,
    )


def _normalize_pit_stop(
    race: RaceSummary,
    session_type: str,
    row: Mapping[str, Any],
    driver_keys_by_number: Mapping[str, str],
) -> NormalizedPitStop:
    return NormalizedPitStop(
        race.season,
        race.round,
        session_type,
        _driver_key(row, driver_keys_by_number),
        1,
        None,
        None,
        {},
    )


def _normalize_weather(
    race: RaceSummary, session_type: str, row: Mapping[str, Any]
) -> NormalizedWeather:
    values = {
        key: Decimal(str(row[key])) if row.get(key) is not None else None
        for key in ("AirTemp", "TrackTemp", "Humidity", "WindSpeed", "Rainfall")
        if key in row
    }
    return NormalizedWeather(
        race.season,
        race.round,
        session_type,
        parse_utc(str(row["Time"])),
        values,
    )
