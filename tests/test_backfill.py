import pytest

from f1sql.backfill import (
    BackfillLedger,
    BackfillReceipt,
    BackfillStatus,
    BackfillTarget,
    next_batch,
)


def test_backfill_batches_are_bounded_resumable_and_fingerprinted() -> None:
    targets = [BackfillTarget(2024, 2), BackfillTarget(2024, 1), BackfillTarget(2023, 1)]
    first = next_batch(targets, {BackfillTarget(2023, 1)}, 1)
    assert first.targets == (BackfillTarget(2024, 1),)
    second = next_batch(targets, set(), 2, first.next_cursor)
    assert second.targets == (BackfillTarget(2024, 2),)
    assert first.fingerprint != second.fingerprint


def test_backfill_rejects_invalid_batch_size() -> None:
    with pytest.raises(ValueError, match="batch_size"):
        next_batch((), set(), 0)


def test_backfill_ledger_is_atomic_idempotent_and_correction_aware(tmp_path) -> None:
    target = BackfillTarget(2024, 1)
    receipt = BackfillReceipt(
        target, BackfillStatus.GAP, "a" * 64, {"Result": 20}, ("FastF1 weather unavailable",)
    )
    ledger = BackfillLedger().record(receipt).record(receipt)
    path = tmp_path / "backfill-ledger.json"
    ledger.write(path)
    assert BackfillLedger.read(path) == ledger
    with pytest.raises(ValueError, match="conflicting receipt"):
        ledger.record(BackfillReceipt(target, BackfillStatus.COMPLETE, "b" * 64, {"Result": 20}))
    correction = BackfillReceipt(
        target, BackfillStatus.COMPLETE, "b" * 64, {"Result": 20}, correction_of="2024.1.0"
    )
    assert len(ledger.record(correction).receipts) == 2
