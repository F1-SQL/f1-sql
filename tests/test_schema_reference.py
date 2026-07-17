import pytest

from f1sql.schema_reference import DatabaseSchemaReference


def test_schema_reference_requires_a_pinned_commit() -> None:
    reference = DatabaseSchemaReference.from_env(
        {
            "F1SQL_DATABASE_REPOSITORY_SHA": "A" * 40,
            "F1SQL_SCHEMA_VERSION": "2.0.0",
        }
    )
    assert reference.commit_sha == "a" * 40
    assert reference.manifest_values()["schema_version"] == "2.0.0"
    assert reference.manifest_values()["database_repository"] == "https://github.com/F1-SQL/f1-sql"
    assert reference.manifest_values()["database_schema_path"] == "database/schema/v2"


def test_schema_reference_rejects_unpinned_or_malformed_commit() -> None:
    with pytest.raises(ValueError):
        DatabaseSchemaReference.from_env({})
    with pytest.raises(ValueError):
        DatabaseSchemaReference.from_env({"F1SQL_DATABASE_REPOSITORY_SHA": "deadbeef"})
