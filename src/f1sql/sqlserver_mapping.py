"""Explicit mappings from normalized load-plan rows to schema-v2 columns."""

from collections.abc import Callable, Mapping
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from .load_plan import LoadPlan, TableLoad
from .sqlserver import StatementFactory, merge_statement

RowMapper = Callable[[Mapping[str, Any], int], tuple[Any, ...]]


def default_statement_factories(schema: str = "f1sql") -> dict[str, StatementFactory]:
    """Return parameterized statement factories for every v2 domain table."""

    definitions: dict[str, tuple[tuple[str, ...], tuple[str, ...], RowMapper]] = {
        "Season": (("SeasonKey",), ("SeasonKey",), lambda row, _: (row["season"],)),
        "Circuit": (
            ("CircuitKey", "Name", "Locality", "Country", "Latitude", "Longitude"),
            ("CircuitKey",),
            lambda row, _: (
                row["key"],
                row["name"],
                row.get("locality"),
                row.get("country"),
                row.get("latitude"),
                row.get("longitude"),
            ),
        ),
        "Driver": (
            ("DriverKey", "GivenName", "FamilyName", "PermanentNumber"),
            ("DriverKey",),
            lambda row, _: (
                row["key"],
                row["given_name"],
                row["family_name"],
                row.get("permanent_number"),
            ),
        ),
        "Constructor": (
            ("ConstructorKey", "Name"),
            ("ConstructorKey",),
            lambda row, _: (row["key"], row["name"]),
        ),
        "Meeting": (
            (
                "MeetingKey",
                "SeasonKey",
                "RoundNumber",
                "Name",
                "ScheduledAtUtc",
                "CircuitKey",
                "HasSprint",
            ),
            ("MeetingKey",),
            lambda row, _: (
                _meeting_key(row),
                row["season"],
                row["round"],
                row["name"],
                row["scheduled_at_utc"],
                row["circuit_key"],
                row["has_sprint"],
            ),
        ),
        "Session": (
            ("SessionKey", "MeetingKey", "SessionType", "StartUtc", "EndUtc", "Status"),
            ("SessionKey",),
            lambda row, _: (
                _session_key(row),
                _meeting_key(row),
                row["session_type"],
                row.get("start_utc"),
                row.get("end_utc"),
                row.get("status", "complete"),
            ),
        ),
        "Participant": (
            ("SessionKey", "DriverKey", "ConstructorKey", "DriverNumber"),
            ("SessionKey", "DriverKey"),
            lambda row, _: (
                _session_key(row),
                row["driver_key"],
                row["constructor_key"],
                row.get("driver_number"),
            ),
        ),
        "Result": (
            (
                "SessionKey",
                "DriverKey",
                "ConstructorKey",
                "DriverNumber",
                "ClassifiedPosition",
                "PositionText",
                "Points",
                "Laps",
                "DurationMs",
                "Status",
            ),
            ("SessionKey", "DriverKey"),
            lambda row, _: (
                _session_key(row),
                row["driver_key"],
                row["constructor_key"],
                row.get("driver_number"),
                row.get("position"),
                row.get("position_text"),
                row["points"],
                row.get("laps"),
                row.get("duration_ms"),
                row.get("status"),
            ),
        ),
        "Lap": (
            (
                "SessionKey",
                "DriverKey",
                "LapNumber",
                "LapTimeMs",
                "Sector1TimeMs",
                "Sector2TimeMs",
                "Sector3TimeMs",
                "SpeedI1Kph",
                "SpeedI2Kph",
                "SpeedFlKph",
                "SpeedStKph",
            ),
            ("SessionKey", "DriverKey", "LapNumber"),
            lambda row, _: (
                _session_key(row),
                row["driver_key"],
                row["lap_number"],
                row.get("lap_time_ms"),
                row["sector_times_ms"][0],
                row["sector_times_ms"][1],
                row["sector_times_ms"][2],
                row.get("speeds_kph", {}).get("SpeedI1"),
                row.get("speeds_kph", {}).get("SpeedI2"),
                row.get("speeds_kph", {}).get("SpeedFL"),
                row.get("speeds_kph", {}).get("SpeedST"),
            ),
        ),
        "Stint": (
            (
                "SessionKey",
                "DriverKey",
                "StintNumber",
                "Compound",
                "StartLap",
                "EndLap",
                "FreshTyre",
            ),
            ("SessionKey", "DriverKey", "StintNumber"),
            lambda row, _: (
                _session_key(row),
                row["driver_key"],
                row["stint_number"],
                row.get("compound"),
                row.get("start_lap"),
                row.get("end_lap"),
                row.get("fresh_tyre"),
            ),
        ),
        "PitStop": (
            (
                "SessionKey",
                "DriverKey",
                "StopNumber",
                "LapNumber",
                "DurationMs",
                "PitInUtc",
                "PitOutUtc",
            ),
            ("SessionKey", "DriverKey", "StopNumber"),
            lambda row, _: (
                _session_key(row),
                row["driver_key"],
                row["stop_number"],
                row.get("lap_number"),
                row.get("duration_ms"),
                row.get("pit_in_utc"),
                row.get("pit_out_utc"),
            ),
        ),
        "Weather": (
            (
                "SessionKey",
                "ObservedAtUtc",
                "AirTempC",
                "TrackTempC",
                "HumidityPct",
                "WindSpeedKph",
                "RainfallMm",
            ),
            ("SessionKey", "ObservedAtUtc"),
            lambda row, _: (
                _session_key(row),
                row["observed_at_utc"],
                row.get("values", {}).get("AirTemp"),
                row.get("values", {}).get("TrackTemp"),
                row.get("values", {}).get("Humidity"),
                row.get("values", {}).get("WindSpeed"),
                row.get("values", {}).get("Rainfall"),
            ),
        ),
        "RaceControl": (
            ("SessionKey", "MessageNumber", "MessageAtUtc", "Category", "Message"),
            ("SessionKey", "MessageNumber"),
            lambda row, index: (
                _session_key(row),
                index,
                row.get("message_at_utc"),
                row.get("category"),
                row["message"],
            ),
        ),
    }
    factories: dict[str, StatementFactory] = {}
    for table, (columns, keys, mapper) in definitions.items():
        statement = merge_statement(table, columns, keys, schema)

        def factory(
            operation: TableLoad,
            *,
            statement: str = statement,
            mapper: RowMapper = mapper,
            table_name: str = table,
        ) -> tuple[str, tuple[tuple[Any, ...], ...]]:
            if table_name == "RaceControl":
                counters: dict[str, int] = {}
                parameters = []
                for row in operation.rows:
                    session = _session_key(row)
                    counters[session] = counters.get(session, 0) + 1
                    parameters.append(mapper(row, counters[session]))
                return statement, tuple(parameters)
            return statement, tuple(
                mapper(row, index + 1) for index, row in enumerate(operation.rows)
            )

        factories[table] = factory
    return factories


def render_load_plan_sql(plan: LoadPlan, schema: str = "f1sql") -> str:
    """Render a load plan as auditable, parameter-bound T-SQL for ``sqlcmd``."""

    factories = default_statement_factories(schema)
    statements: list[str] = ["SET XACT_ABORT ON;", "BEGIN TRANSACTION;"]
    for operation in plan.operations:
        if not operation.rows:
            continue
        statement, parameters = factories[operation.table](operation)
        for values in parameters:
            statements.append(_bind_parameters(statement, values))
    statements.extend(("COMMIT TRANSACTION;", ""))
    return "\n".join(statements)


def _bind_parameters(statement: str, parameters: tuple[Any, ...]) -> str:
    pieces = statement.split("?")
    if len(pieces) != len(parameters) + 1:
        raise ValueError("statement placeholder count does not match parameters")
    return "".join(
        piece + (_sql_literal(parameters[index]) if index < len(parameters) else "")
        for index, piece in enumerate(pieces)
    )


def _sql_literal(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (int, Decimal, float)):
        return str(value)
    if isinstance(value, datetime):
        normalized = value.replace(tzinfo=None).isoformat(timespec="milliseconds")
        return f"CONVERT(datetime2(3), N'{normalized}', 126)"
    if isinstance(value, date):
        return f"CONVERT(date, N'{value.isoformat()}', 23)"
    escaped = str(value).replace("'", "''")
    return f"N'{escaped}'"


def _meeting_key(row: Mapping[str, Any]) -> str:
    return f"{row['season']}.{row['round']}"


def _session_key(row: Mapping[str, Any]) -> str:
    value = row.get("session_key")
    if isinstance(value, (tuple, list)):
        return ".".join(str(item) for item in value)
    if value is not None:
        return str(value)
    return f"{_meeting_key(row)}.{row['session_type']}"
