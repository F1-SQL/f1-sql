from dataclasses import replace

from f1sql.load_plan import TABLE_ORDER, build_load_plan, reconcile_load_plan
from f1sql.normalization import NormalizationBundle, NormalizedMeeting


def test_load_plan_is_ordered_and_repeatable() -> None:
    plan = build_load_plan(NormalizationBundle())
    assert tuple(operation.table for operation in plan.operations) == TABLE_ORDER
    assert plan.fingerprint() == build_load_plan(NormalizationBundle()).fingerprint()


def test_load_plan_sorts_rows_and_dedicated_participants() -> None:
    plan = build_load_plan(NormalizationBundle())
    participant = next(
        operation for operation in plan.operations if operation.table == "Participant"
    )
    assert participant.rows == ()


def test_load_plan_reconciliation_detects_missing_normalized_rows() -> None:
    from datetime import UTC, datetime

    meeting = NormalizedMeeting(
        2024,
        1,
        "Bahrain",
        datetime(2024, 3, 2, tzinfo=UTC),
        "circuit:bahrain",
        {},
        False,
    )
    bundle = NormalizationBundle(meetings=(meeting,))
    plan = build_load_plan(bundle)
    season = next(operation for operation in plan.operations if operation.table == "Season")
    damaged = replace(plan, operations=tuple(
        replace(operation, rows=()) if operation is season else operation
        for operation in plan.operations
    ))
    assert any(
        "Season row count differs" in issue for issue in reconcile_load_plan(bundle, damaged)
    )
