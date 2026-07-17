"""Machine-readable quality rules and fail-closed normalized-data reports."""

from collections.abc import Callable, Iterable, Mapping
from dataclasses import asdict, dataclass
from enum import StrEnum
from pathlib import Path
from typing import Any, cast

from .fingerprint import canonical_json, sha256_json
from .load_plan import LoadPlan, reconcile_load_plan
from .normalization import DiscrepancySeverity, NormalizationBundle


class QualitySeverity(StrEnum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"


@dataclass(frozen=True, slots=True)
class QualityRule:
    rule_id: str
    severity: QualitySeverity
    description: str


@dataclass(frozen=True, slots=True)
class QualityIssue:
    rule_id: str
    message: str
    evidence: Mapping[str, Any]


@dataclass(frozen=True, slots=True)
class CoverageGap:
    source: str
    domain: str
    reason: str
    severity: QualitySeverity = QualitySeverity.INFO


@dataclass(frozen=True, slots=True)
class CoverageExpectation:
    domain: str
    key: tuple[Any, ...]
    source: str
    minimum_rows: int = 1
    allow_gap: bool = False
    reason: str = "provider did not return the expected records"


@dataclass(frozen=True, slots=True)
class RuleResult:
    rule: QualityRule
    passed: bool
    row_count: int
    issues: tuple[QualityIssue, ...] = ()


@dataclass(frozen=True, slots=True)
class QualityReport:
    rules: tuple[RuleResult, ...]
    coverage_gaps: tuple[CoverageGap, ...] = ()

    @property
    def passed(self) -> bool:
        return all(
            result.passed or result.rule.severity is not QualitySeverity.ERROR
            for result in self.rules
        )

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    def to_json(self) -> str:
        return canonical_json(self.to_dict())

    def write(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(self.to_json() + "\n", encoding="utf-8")

    def fingerprint(self) -> str:
        return sha256_json(self.to_dict())


DEFAULT_RULES: tuple[QualityRule, ...] = (
    QualityRule(
        "meeting.key_unique", QualitySeverity.ERROR, "Each meeting season/round key occurs once."
    ),
    QualityRule(
        "result.key_unique", QualitySeverity.ERROR, "Each result session/driver key occurs once."
    ),
    QualityRule(
        "session.key_unique",
        QualitySeverity.ERROR,
        "Each session season/round/type key occurs once.",
    ),
    QualityRule(
        "lap.key_unique", QualitySeverity.ERROR, "Each driver lap key occurs once."
    ),
    QualityRule(
        "stint.key_unique", QualitySeverity.ERROR, "Each driver stint key occurs once."
    ),
    QualityRule(
        "result.required_identity",
        QualitySeverity.ERROR,
        "Each result has driver and constructor identities.",
    ),
    QualityRule(
        "result.points_non_negative",
        QualitySeverity.ERROR,
        "Championship points cannot be negative.",
    ),
    QualityRule(
        "normalization.discrepancy_errors",
        QualitySeverity.ERROR,
        "Error-severity reconciliation discrepancies block release.",
    ),
    QualityRule(
        "result.meeting_reference",
        QualitySeverity.ERROR,
        "Every result references a normalized meeting.",
    ),
    QualityRule(
        "session.meeting_reference",
        QualitySeverity.ERROR,
        "Every session references a normalized meeting.",
    ),
    QualityRule(
        "lap.session_reference", QualitySeverity.ERROR, "Every lap references a normalized session."
    ),
    QualityRule(
        "stint.session_reference",
        QualitySeverity.ERROR,
        "Every stint references a normalized session.",
    ),
    QualityRule(
        "pit_stop.session_reference",
        QualitySeverity.ERROR,
        "Every pit stop references a normalized session.",
    ),
    QualityRule(
        "weather.session_reference",
        QualitySeverity.ERROR,
        "Every weather observation references a normalized session.",
    ),
    QualityRule(
        "race_control.session_reference",
        QualitySeverity.ERROR,
        "Every race-control message references a normalized session.",
    ),
    QualityRule(
        "coverage.required",
        QualitySeverity.ERROR,
        "Required event/session domain coverage meets its minimum row count.",
    ),
    QualityRule(
        "load_plan.row_counts",
        QualitySeverity.ERROR,
        "The normalized bundle and database load plan contain identical table counts.",
    ),
)


def _unique_rule(
    rule: QualityRule, keys: Iterable[tuple[Any, ...]], row_count: int
) -> RuleResult:
    seen: set[tuple[Any, ...]] = set()
    issues: list[QualityIssue] = []
    for key in keys:
        if key in seen:
            issues.append(QualityIssue(rule.rule_id, "duplicate key", {"key": key}))
        seen.add(key)
    return RuleResult(rule, not issues, row_count, tuple(issues))


def _reference_rule(
    rule: QualityRule,
    keys: Iterable[tuple[Any, ...]],
    references: set[tuple[Any, ...]],
    row_count: int,
) -> RuleResult:
    issues = tuple(
        QualityIssue(rule.rule_id, "orphan reference", {"key": key})
        for key in keys
        if key not in references
    )
    return RuleResult(rule, not issues, row_count, issues)


def _coverage_counts(bundle: NormalizationBundle) -> dict[str, dict[tuple[Any, ...], int]]:
    def count(
        rows: Iterable[Any], key: Callable[[Any], tuple[Any, ...]]
    ) -> dict[tuple[Any, ...], int]:
        counts: dict[tuple[Any, ...], int] = {}
        for row in rows:
            row_key = key(row)
            counts[row_key] = counts.get(row_key, 0) + 1
        return counts

    def session_key(row: Any) -> tuple[Any, ...]:
        return row.season, row.round, row.session_type

    def meeting_key(row: Any) -> tuple[Any, ...]:
        return row.season, row.round
    return {
        "meeting": count(bundle.meetings, meeting_key),
        "session": count(bundle.sessions, session_key),
        "participant": count(bundle.results, session_key),
        "result": count(bundle.results, session_key),
        "lap": count(bundle.laps, session_key),
        "stint": count(bundle.stints, session_key),
        "pit_stop": count(bundle.pit_stops, session_key),
        "weather": count(bundle.weather, session_key),
        "race_control": count(bundle.race_control, session_key),
    }


def _coverage_rule(
    rule: QualityRule,
    bundle: NormalizationBundle,
    expectations: tuple[CoverageExpectation, ...],
) -> tuple[RuleResult, tuple[CoverageGap, ...]]:
    counts = _coverage_counts(bundle)
    issues: list[QualityIssue] = []
    gaps: list[CoverageGap] = []
    for expectation in expectations:
        actual = counts.get(expectation.domain, {}).get(expectation.key, 0)
        if actual >= expectation.minimum_rows:
            continue
        evidence = {
            "domain": expectation.domain,
            "key": expectation.key,
            "expected_minimum": expectation.minimum_rows,
            "actual": actual,
            "source": expectation.source,
        }
        if expectation.allow_gap:
            gaps.append(
                CoverageGap(expectation.source, expectation.domain, expectation.reason)
            )
        else:
            issues.append(QualityIssue(rule.rule_id, "required coverage missing", evidence))
    row_count = sum(counts.get(item.domain, {}).get(item.key, 0) for item in expectations)
    return RuleResult(rule, not issues, row_count, tuple(issues)), tuple(gaps)


def validate_bundle(
    bundle: NormalizationBundle,
    rules: tuple[QualityRule, ...] = DEFAULT_RULES,
    coverage_gaps: tuple[CoverageGap, ...] = (),
    coverage_expectations: tuple[CoverageExpectation, ...] = (),
    load_plan: LoadPlan | None = None,
) -> QualityReport:
    results: list[RuleResult] = []
    generated_gaps: list[CoverageGap] = []
    for rule in rules:
        if rule.rule_id == "meeting.key_unique":
            results.append(
                _unique_rule(
                    rule,
                    ((meeting.season, meeting.round) for meeting in bundle.meetings),
                    len(bundle.meetings),
                )
            )
        elif rule.rule_id == "result.key_unique":
            results.append(
                _unique_rule(
                    rule,
                    (
                        (result.season, result.round, result.session_type, result.driver_key)
                        for result in bundle.results
                    ),
                    len(bundle.results),
                )
            )
        elif rule.rule_id == "session.key_unique":
            results.append(
                _unique_rule(
                    rule,
                    ((item.season, item.round, item.session_type) for item in bundle.sessions),
                    len(bundle.sessions),
                )
            )
        elif rule.rule_id == "lap.key_unique":
            results.append(
                _unique_rule(
                    rule,
                    (
                        (
                            item.season,
                            item.round,
                            item.session_type,
                            item.driver_key,
                            item.lap_number,
                        )
                        for item in bundle.laps
                    ),
                    len(bundle.laps),
                )
            )
        elif rule.rule_id == "stint.key_unique":
            results.append(
                _unique_rule(
                    rule,
                    (
                        (
                            item.season,
                            item.round,
                            item.session_type,
                            item.driver_key,
                            item.stint_number,
                        )
                        for item in bundle.stints
                    ),
                    len(bundle.stints),
                )
            )
        elif rule.rule_id == "result.required_identity":
            issues = tuple(
                QualityIssue(rule.rule_id, "missing result identity", {"index": index})
                for index, result in enumerate(bundle.results)
                if not result.driver_key or not result.constructor_key
            )
            results.append(RuleResult(rule, not issues, len(bundle.results), issues))
        elif rule.rule_id == "result.points_non_negative":
            issues = tuple(
                QualityIssue(
                    rule.rule_id,
                    "negative points",
                    {"index": index, "points": str(result.points)},
                )
                for index, result in enumerate(bundle.results)
                if result.points < 0
            )
            results.append(RuleResult(rule, not issues, len(bundle.results), issues))
        elif rule.rule_id == "normalization.discrepancy_errors":
            issues = tuple(
                QualityIssue(rule.rule_id, discrepancy.message, discrepancy.evidence)
                for discrepancy in bundle.discrepancies
                if discrepancy.severity is DiscrepancySeverity.ERROR
            )
            results.append(RuleResult(rule, not issues, len(bundle.discrepancies), issues))
        elif rule.rule_id == "result.meeting_reference":
            references = {(item.season, item.round) for item in bundle.meetings}
            results.append(
                _reference_rule(
                    rule,
                    ((item.season, item.round) for item in bundle.results),
                    references,
                    len(bundle.results),
                )
            )
        elif rule.rule_id == "session.meeting_reference":
            references = {(item.season, item.round) for item in bundle.meetings}
            results.append(
                _reference_rule(
                    rule,
                    ((item.season, item.round) for item in bundle.sessions),
                    references,
                    len(bundle.sessions),
                )
            )
        elif rule.rule_id.endswith(".session_reference"):
            session_references: set[tuple[Any, ...]] = {
                (item.season, item.round, item.session_type) for item in bundle.sessions
            }
            rows = cast(
                tuple[Any, ...],
                {
                    "lap.session_reference": bundle.laps,
                    "stint.session_reference": bundle.stints,
                    "pit_stop.session_reference": bundle.pit_stops,
                    "weather.session_reference": bundle.weather,
                    "race_control.session_reference": bundle.race_control,
                }[rule.rule_id],
            )
            results.append(
                _reference_rule(
                    rule,
                    ((item.season, item.round, item.session_type) for item in rows),
                    session_references,
                    len(rows),
                )
            )
        elif rule.rule_id == "coverage.required":
            result, gaps = _coverage_rule(rule, bundle, coverage_expectations)
            results.append(result)
            generated_gaps.extend(gaps)
        elif rule.rule_id == "load_plan.row_counts":
            if load_plan is None:
                results.append(RuleResult(rule, True, 0))
            else:
                issues = tuple(
                    QualityIssue(rule.rule_id, issue, {})
                    for issue in reconcile_load_plan(bundle, load_plan)
                )
                results.append(RuleResult(rule, not issues, len(load_plan.operations), issues))
        else:
            raise ValueError(f"unknown quality rule: {rule.rule_id}")
    return QualityReport(tuple(results), (*coverage_gaps, *generated_gaps))
