import pytest

from f1sql.load_plan import LoadPlan, TableLoad
from f1sql.sqlserver import SqlServerLoadError, TransactionalLoader, merge_statement


class FakeCursor:
    def __init__(self, fail_on: str | None = None) -> None:
        self.calls: list[str] = []
        self.fail_on = fail_on

    def executemany(self, statement: str, parameters: tuple[tuple[object, ...], ...]) -> None:
        self.calls.append(statement)
        if statement == self.fail_on:
            raise RuntimeError("constraint violation")


class FakeConnection:
    def __init__(self, fail_on: str | None = None) -> None:
        self.db_cursor = FakeCursor(fail_on)
        self.commits = 0
        self.rollbacks = 0

    def cursor(self) -> FakeCursor:
        return self.db_cursor

    def commit(self) -> None:
        self.commits += 1

    def rollback(self) -> None:
        self.rollbacks += 1


def _factory(operation: TableLoad) -> tuple[str, tuple[tuple[object, ...], ...]]:
    return operation.table, tuple(tuple(row.values()) for row in operation.rows)


def test_transactional_loader_orders_and_commits() -> None:
    plan = LoadPlan(
        (
            TableLoad("Season", ("season",), ({"season": 2024},)),
            TableLoad("Meeting", ("meeting",), ({"meeting": "2024.1"},)),
        )
    )
    connection = FakeConnection()
    TransactionalLoader().load(plan, connection, {"Season": _factory, "Meeting": _factory})
    assert connection.db_cursor.calls == ["Season", "Meeting"]
    assert connection.commits == 1
    assert connection.rollbacks == 0


def test_transactional_loader_rolls_back_on_error() -> None:
    plan = LoadPlan((TableLoad("Season", ("season",), ({"season": 2024},)),))
    connection = FakeConnection("Season")
    with pytest.raises(SqlServerLoadError):
        TransactionalLoader().load(plan, connection, {"Season": _factory})
    assert connection.commits == 0
    assert connection.rollbacks == 1


def test_merge_statement_is_parameterized_and_idempotent() -> None:
    statement = merge_statement(
        "Result",
        ("season", "round", "driver_key", "points"),
        ("season", "round", "driver_key"),
    )
    assert "MERGE INTO [dbo].[Result]" in statement
    assert "USING (VALUES (?, ?, ?, ?))" in statement
    assert "target.[points] = source.[points]" in statement
    assert "WHEN NOT MATCHED THEN INSERT" in statement
    assert "'" not in statement


def test_merge_statement_rejects_unsafe_identifiers() -> None:
    with pytest.raises(ValueError, match="unsafe SQL identifier"):
        merge_statement("Result; DROP TABLE Driver", ("id",), ("id",))


def test_merge_statement_allows_key_only_rows_without_update_clause() -> None:
    statement = merge_statement("Season", ("season",), ("season",))
    assert "WHEN MATCHED" not in statement
