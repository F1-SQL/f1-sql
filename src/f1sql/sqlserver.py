"""SQL Server execution boundary for deterministic load plans.

The adapter deliberately depends on a tiny DB-API-like protocol so tests can
exercise transaction behaviour without requiring a live SQL Server instance.
"""

import re
from collections.abc import Callable, Mapping, Sequence
from typing import Any, Protocol

from .load_plan import LoadPlan, TableLoad


class Cursor(Protocol):
    def executemany(self, statement: str, parameters: Sequence[Sequence[Any]]) -> Any: ...


class Connection(Protocol):
    def cursor(self) -> Cursor: ...

    def commit(self) -> Any: ...

    def rollback(self) -> Any: ...


StatementFactory = Callable[[TableLoad], tuple[str, tuple[tuple[Any, ...], ...]]]


class SqlServerLoadError(RuntimeError):
    pass


_IDENTIFIER = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def _quote_identifier(value: str) -> str:
    """Quote a schema/table/column name after rejecting ambiguous input."""

    if not _IDENTIFIER.fullmatch(value):
        raise ValueError(f"unsafe SQL identifier: {value!r}")
    return f"[{value}]"


def merge_statement(
    table: str,
    columns: Sequence[str],
    key_columns: Sequence[str],
    schema: str = "dbo",
) -> str:
    """Build a parameterized, idempotent SQL Server ``MERGE`` statement.

    The generated statement is intentionally small and deterministic. Values
    are supplied through DB-API parameters, while identifiers are validated
    and quoted. A caller should execute it once per row (or provide a driver
    that supports ``executemany`` for the statement).
    """

    ordered_columns = tuple(columns)
    keys = tuple(key_columns)
    if not ordered_columns or not keys:
        raise ValueError("MERGE requires columns and at least one key column")
    if len(set(ordered_columns)) != len(ordered_columns):
        raise ValueError("MERGE columns must be unique")
    if any(key not in ordered_columns for key in keys):
        raise ValueError("MERGE key columns must be present in columns")
    quoted_schema = _quote_identifier(schema)
    quoted_table = _quote_identifier(table)
    quoted_columns = tuple(_quote_identifier(column) for column in ordered_columns)
    quoted_keys = tuple(_quote_identifier(key) for key in keys)
    source_columns = ", ".join(quoted_columns)
    placeholders = ", ".join("?" for _ in ordered_columns)
    predicate = " AND ".join(f"target.{key} = source.{key}" for key in quoted_keys)
    updates = tuple(column for column in quoted_columns if column not in quoted_keys)
    update_clause = ""
    if updates:
        update_clause = " WHEN MATCHED THEN UPDATE SET " + ", ".join(
            f"target.{column} = source.{column}" for column in updates
        )
    insert_columns = ", ".join(quoted_columns)
    insert_values = ", ".join(f"source.{column}" for column in quoted_columns)
    return (
        f"MERGE INTO {quoted_schema}.{quoted_table} AS target "
        f"USING (VALUES ({placeholders})) AS source ({source_columns}) "
        f"ON {predicate}{update_clause} "
        f"WHEN NOT MATCHED THEN INSERT ({insert_columns}) VALUES ({insert_values});"
    )


class TransactionalLoader:
    """Execute a load plan in order and fail closed on the first statement error."""

    def load(
        self,
        plan: LoadPlan,
        connection: Connection,
        statements: Mapping[str, StatementFactory],
    ) -> None:
        cursor = connection.cursor()
        try:
            for operation in plan.operations:
                if not operation.rows:
                    continue
                factory = statements.get(operation.table)
                if factory is None:
                    raise SqlServerLoadError(f"no statement factory for {operation.table}")
                statement, parameters = factory(operation)
                cursor.executemany(statement, parameters)
            connection.commit()
        except Exception as exc:
            connection.rollback()
            if isinstance(exc, SqlServerLoadError):
                raise
            raise SqlServerLoadError("SQL Server load rolled back") from exc
