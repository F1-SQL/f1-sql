from decimal import Decimal

from f1sql.load_plan import TABLE_ORDER, TableLoad
from f1sql.sqlserver_mapping import default_statement_factories, render_load_plan_sql


def test_default_factories_cover_every_domain_table_and_use_v2_schema() -> None:
    factories = default_statement_factories()
    assert tuple(factories) == TABLE_ORDER
    operation = TableLoad("Season", ("season",), ({"season": 2024},))
    statement, parameters = factories["Season"](operation)
    assert "MERGE INTO [f1sql].[Season]" in statement
    assert parameters == ((2024,),)


def test_result_mapping_uses_schema_columns_and_string_session_key() -> None:
    factories = default_statement_factories("f1sql")
    operation = TableLoad(
        "Result",
        ("season", "round", "session_type", "driver_key"),
        (
            {
                "season": 2024,
                "round": 1,
                "session_type": "race",
                "driver_key": "driver:max",
                "constructor_key": "constructor:red-bull",
                "driver_number": 1,
                "position": 1,
                "position_text": "1",
                "points": Decimal("25"),
                "laps": 57,
                "duration_ms": 5_504_742,
                "status": "Finished",
            },
        ),
    )
    statement, parameters = factories["Result"](operation)
    assert "[ClassifiedPosition]" in statement
    assert parameters[0][:4] == ("2024.1.race", "driver:max", "constructor:red-bull", 1)


def test_race_control_mapping_assigns_deterministic_message_numbers() -> None:
    factory = default_statement_factories()["RaceControl"]
    operation = TableLoad(
        "RaceControl",
        (),
        (
            {"season": 2024, "round": 1, "session_type": "race", "message": "GREEN"},
            {"season": 2024, "round": 1, "session_type": "race", "message": "CHEQUERED"},
        ),
    )
    _, parameters = factory(operation)
    assert [row[1] for row in parameters] == [1, 2]


def test_render_load_plan_sql_binds_values_and_wraps_one_transaction() -> None:
    from f1sql.load_plan import LoadPlan

    plan = LoadPlan((TableLoad("Season", ("season",), ({"season": 2024},)),))
    rendered = render_load_plan_sql(plan)
    assert rendered.startswith("SET XACT_ABORT ON;\nBEGIN TRANSACTION;")
    assert "VALUES (2024)" in rendered
    assert "?" not in rendered
    assert rendered.rstrip().endswith("COMMIT TRANSACTION;")
