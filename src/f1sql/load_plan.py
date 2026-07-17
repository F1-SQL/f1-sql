"""Deterministic database load ordering and idempotency keys."""

from collections.abc import Mapping
from dataclasses import asdict, dataclass
from datetime import date, datetime, time
from decimal import Decimal
from typing import Any

from .fingerprint import canonical_json, sha256_json
from .normalization import NormalizationBundle

TABLE_ORDER = (
    "Season",
    "Circuit",
    "Driver",
    "Constructor",
    "Meeting",
    "Session",
    "Participant",
    "Result",
    "Lap",
    "Stint",
    "PitStop",
    "Weather",
    "RaceControl",
)


@dataclass(frozen=True, slots=True)
class TableLoad:
    table: str
    key_columns: tuple[str, ...]
    rows: tuple[dict[str, Any], ...]


@dataclass(frozen=True, slots=True)
class LoadPlan:
    operations: tuple[TableLoad, ...]

    def fingerprint(self) -> str:
        return sha256_json(_jsonable(asdict(self)))

    def to_json(self) -> str:
        return canonical_json(_jsonable(asdict(self)))


def expected_row_counts(bundle: NormalizationBundle) -> dict[str, int]:
    """Calculate table counts independently of the load-plan construction."""

    participant_keys = {
        (item.season, item.round, item.session_type, item.driver_key)
        for item in bundle.results
    }
    return {
        "Season": len({item.season for item in bundle.meetings}),
        "Circuit": len(bundle.circuits),
        "Driver": len(bundle.drivers),
        "Constructor": len(bundle.constructors),
        "Meeting": len(bundle.meetings),
        "Session": len(bundle.sessions),
        "Participant": len(participant_keys),
        "Result": len(bundle.results),
        "Lap": len(bundle.laps),
        "Stint": len(bundle.stints),
        "PitStop": len(bundle.pit_stops),
        "Weather": len(bundle.weather),
        "RaceControl": len(bundle.race_control),
    }


def reconcile_load_plan(bundle: NormalizationBundle, plan: LoadPlan) -> tuple[str, ...]:
    """Check that a plan contains every normalized table row exactly once."""

    expected = expected_row_counts(bundle)
    actual = {operation.table: len(operation.rows) for operation in plan.operations}
    issues: list[str] = []
    if tuple(operation.table for operation in plan.operations) != TABLE_ORDER:
        issues.append("load plan table order differs from TABLE_ORDER")
    for table in TABLE_ORDER:
        if actual.get(table) != expected[table]:
            issues.append(
                f"{table} row count differs: expected {expected[table]}, got {actual.get(table, 0)}"
            )
    return tuple(issues)


def _rows(values: tuple[Any, ...], key_columns: tuple[str, ...]) -> tuple[dict[str, Any], ...]:
    records = [dict(value) if isinstance(value, Mapping) else asdict(value) for value in values]
    return tuple(
        sorted(records, key=lambda row: tuple(str(row.get(column, "")) for column in key_columns))
    )


def _jsonable(value: Any) -> Any:
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, (datetime, date, time)):
        return value.isoformat().replace("+00:00", "Z")
    if isinstance(value, Mapping):
        return {str(key): _jsonable(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [_jsonable(item) for item in value]
    return value


def build_load_plan(bundle: NormalizationBundle) -> LoadPlan:
    """Prepare rows in FK-safe order; execution remains a separate SQL adapter."""

    seasons = tuple(
        {"season": season}
        for season in sorted({meeting.season for meeting in bundle.meetings})
    )
    operations: list[TableLoad] = [
        TableLoad("Season", ("season",), _rows(seasons, ("season",))),
        TableLoad("Circuit", ("key",), _rows(bundle.circuits, ("key",))),
        TableLoad("Driver", ("key",), _rows(bundle.drivers, ("key",))),
        TableLoad("Constructor", ("key",), _rows(bundle.constructors, ("key",))),
        TableLoad(
            "Meeting", ("season", "round"), _rows(bundle.meetings, ("season", "round"))
        ),
        TableLoad(
            "Session",
            ("season", "round", "session_type"),
            _rows(bundle.sessions, ("season", "round", "session_type")),
        ),
        TableLoad(
            "Result",
            ("season", "round", "session_type", "driver_key"),
            _rows(bundle.results, ("season", "round", "session_type", "driver_key")),
        ),
        TableLoad(
            "Lap",
            ("season", "round", "session_type", "driver_key", "lap_number"),
            _rows(bundle.laps, ("season", "round", "session_type", "driver_key", "lap_number")),
        ),
        TableLoad(
            "Stint",
            ("season", "round", "session_type", "driver_key", "stint_number"),
            _rows(bundle.stints, ("season", "round", "session_type", "driver_key", "stint_number")),
        ),
        TableLoad(
            "PitStop",
            ("season", "round", "session_type", "driver_key", "stop_number"),
            _rows(
                bundle.pit_stops,
                ("season", "round", "session_type", "driver_key", "stop_number"),
            ),
        ),
        TableLoad(
            "Weather",
            ("season", "round", "session_type", "observed_at_utc"),
            _rows(bundle.weather, ("season", "round", "session_type", "observed_at_utc")),
        ),
        TableLoad(
            "RaceControl",
            ("season", "round", "session_type", "message"),
            _rows(bundle.race_control, ("season", "round", "session_type", "message")),
        ),
    ]
    participants = tuple(
        {
            "session_key": (result.season, result.round, result.session_type),
            "driver_key": result.driver_key,
            "constructor_key": result.constructor_key,
            "driver_number": result.driver_number,
        }
        for result in bundle.results
    )
    operations.insert(
        6,
        TableLoad(
            "Participant",
            ("session_key", "driver_key"),
            _rows(participants, ("session_key", "driver_key")),
        ),
    )
    return LoadPlan(tuple(operations))
