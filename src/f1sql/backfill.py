"""Deterministic cursors and provenance ledger for historical backfills."""

import json
from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from typing import Any

from .contracts import BuildTarget
from .fingerprint import canonical_json, sha256_json


@dataclass(frozen=True, order=True, slots=True)
class BackfillTarget:
    season: int
    round: int

    def build_target(self) -> BuildTarget:
        return BuildTarget(self.season, self.round)


class BackfillStatus(StrEnum):
    COMPLETE = "complete"
    GAP = "gap"
    FAILED = "failed"


@dataclass(frozen=True, slots=True)
class BackfillReceipt:
    target: BackfillTarget
    status: BackfillStatus
    source_fingerprint: str
    row_counts: Mapping[str, int]
    gaps: tuple[str, ...] = ()
    correction_of: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "target": {"season": self.target.season, "round": self.target.round},
            "status": self.status.value,
            "source_fingerprint": self.source_fingerprint,
            "row_counts": dict(self.row_counts),
            "gaps": list(self.gaps),
            "correction_of": self.correction_of,
        }


@dataclass(frozen=True, slots=True)
class BackfillBatch:
    targets: tuple[BackfillTarget, ...]
    next_cursor: BackfillTarget | None

    @property
    def fingerprint(self) -> str:
        return sha256_json(
            {
                "targets": [(item.season, item.round) for item in self.targets],
                "next_cursor": (
                    (self.next_cursor.season, self.next_cursor.round)
                    if self.next_cursor
                    else None
                ),
            }
        )


@dataclass(frozen=True, slots=True)
class BackfillLedger:
    receipts: tuple[BackfillReceipt, ...] = ()

    def record(self, receipt: BackfillReceipt) -> "BackfillLedger":
        existing = next(
            (
                item
                for item in self.receipts
                if item.target == receipt.target and item.correction_of is None
            ),
            None,
        )
        if (
            existing is not None
            and receipt.correction_of is None
            and existing.source_fingerprint != receipt.source_fingerprint
        ):
            raise ValueError(
                f"conflicting receipt for {receipt.target.season}.{receipt.target.round}; "
                "use correction_of to replace an existing release"
            )
        if existing is not None and receipt.correction_of is None:
            return self
        return BackfillLedger(
            tuple(sorted((*self.receipts, receipt), key=lambda item: item.target))
        )

    def write(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        payload = {"version": 1, "receipts": [item.to_dict() for item in self.receipts]}
        temporary = path.with_suffix(f"{path.suffix}.tmp")
        temporary.write_text(canonical_json(payload) + "\n", encoding="utf-8")
        temporary.replace(path)

    @classmethod
    def read(cls, path: Path) -> "BackfillLedger":
        payload = json.loads(path.read_text(encoding="utf-8"))
        if payload.get("version") != 1:
            raise ValueError("unsupported backfill ledger version")
        receipts = tuple(
            BackfillReceipt(
                BackfillTarget(int(item["target"]["season"]), int(item["target"]["round"])),
                BackfillStatus(item["status"]),
                str(item["source_fingerprint"]),
                {str(key): int(value) for key, value in item.get("row_counts", {}).items()},
                tuple(str(gap) for gap in item.get("gaps", [])),
                item.get("correction_of"),
            )
            for item in payload.get("receipts", [])
        )
        return cls(receipts)


def next_batch(
    targets: Iterable[BackfillTarget],
    completed: set[BackfillTarget],
    batch_size: int,
    cursor: BackfillTarget | None = None,
) -> BackfillBatch:
    """Select the next deterministic, not-yet-completed batch."""

    if batch_size <= 0:
        raise ValueError("batch_size must be positive")
    ordered = sorted(set(targets))
    pending = [
        item
        for item in ordered
        if item not in completed and (cursor is None or item > cursor)
    ]
    selected = tuple(pending[:batch_size])
    next_cursor = selected[-1] if selected else cursor
    return BackfillBatch(selected, next_cursor)
