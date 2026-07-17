from decimal import Decimal

from f1sql.normalization import (
    Discrepancy,
    DiscrepancySeverity,
    NormalizationBundle,
    NormalizedMeeting,
    NormalizedResult,
)
from f1sql.quality import (
    CoverageExpectation,
    CoverageGap,
    QualitySeverity,
    validate_bundle,
)


def _meeting() -> NormalizedMeeting:
    from datetime import UTC, datetime

    return NormalizedMeeting(
        2024,
        1,
        "Bahrain",
        datetime(2024, 3, 2, tzinfo=UTC),
        "circuit:bahrain",
        {},
        True,
    )


def _result(points: str = "25") -> NormalizedResult:
    return NormalizedResult(
        2024,
        1,
        "race",
        "driver:max",
        "constructor:red-bull",
        33,
        1,
        "1",
        Decimal(points),
        57,
        5_504_742,
        "Finished",
        {},
    )


def test_quality_report_passes_good_bundle() -> None:
    report = validate_bundle(NormalizationBundle(meetings=(_meeting(),), results=(_result(),)))
    assert report.passed is True
    assert report.fingerprint() == report.fingerprint()


def test_quality_report_writes_machine_readable_output(tmp_path) -> None:
    report = validate_bundle(NormalizationBundle(meetings=(_meeting(),), results=(_result(),)))
    output = tmp_path / "quality-report.json"
    report.write(output)
    contents = output.read_text(encoding="utf-8")
    assert '"rules"' in contents
    assert '"row_count":1' in contents


def test_quality_report_separates_coverage_gaps_from_defects() -> None:
    report = validate_bundle(
        NormalizationBundle(),
        coverage_gaps=(CoverageGap("fastf1", "telemetry", "pre-2018 unsupported"),),
    )
    assert report.passed is True
    assert report.coverage_gaps[0].severity is QualitySeverity.INFO


def test_quality_report_fails_duplicates_and_negative_points() -> None:
    bundle = NormalizationBundle(
        meetings=(_meeting(), _meeting()), results=(_result("-1"), _result("-1"))
    )
    report = validate_bundle(bundle)
    assert report.passed is False
    assert any(not result.passed for result in report.rules)


def test_quality_report_checks_lap_and_session_keys() -> None:
    from datetime import UTC, datetime

    from f1sql.normalization import NormalizedLap, NormalizedSession

    session = NormalizedSession(2024, 1, "race", datetime(2024, 3, 2, tzinfo=UTC), None, {})
    lap = NormalizedLap(2024, 1, "race", "driver:max", 1, 1000, (None, None, None), {}, {})
    report = validate_bundle(
        NormalizationBundle(sessions=(session, session), laps=(lap, lap))
    )
    assert report.passed is False
    assert any(
        result.rule.rule_id == "lap.key_unique" and not result.passed
        for result in report.rules
    )


def test_quality_report_blocks_error_discrepancies() -> None:
    discrepancy = Discrepancy(
        "result", "winner", DiscrepancySeverity.ERROR, "conflict", {"a": 1, "b": 2}
    )
    report = validate_bundle(NormalizationBundle(discrepancies=(discrepancy,)))
    assert report.passed is False


def test_quality_report_detects_orphan_references() -> None:
    report = validate_bundle(NormalizationBundle(results=(_result(),)))
    orphan = next(item for item in report.rules if item.rule.rule_id == "result.meeting_reference")
    assert orphan.passed is False
    assert orphan.issues[0].message == "orphan reference"


def test_quality_report_distinguishes_required_coverage_from_allowed_gap() -> None:
    required = validate_bundle(
        NormalizationBundle(meetings=(_meeting(),)),
        coverage_expectations=(CoverageExpectation("session", (2024, 1, "race"), "fastf1"),),
    )
    assert required.passed is False
    allowed = validate_bundle(
        NormalizationBundle(meetings=(_meeting(),)),
        coverage_expectations=(
            CoverageExpectation(
                "session",
                (2024, 1, "race"),
                "fastf1",
                allow_gap=True,
                reason="historical session unavailable",
            ),
        ),
    )
    assert allowed.passed is True
    assert allowed.coverage_gaps[0].reason == "historical session unavailable"
