from pathlib import Path

from f1sql.schema_validation import validate_schema_directory


def test_v2_schema_scripts_are_numbered_guarded_and_database_neutral() -> None:
    workspace = Path(__file__).parents[1]
    candidates = (
        workspace.parent / "f1-sql-database" / "schema" / "v2",
        workspace / "f1-sql-database" / "schema" / "v2",
    )
    schema = next((candidate for candidate in candidates if candidate.is_dir()), None)
    assert schema is not None, "f1-sql-database checkout is required for schema validation"
    result = validate_schema_directory(schema)
    assert result.passed, result.issues
    assert result.scripts == (
        "0001_metadata.sql",
        "0002_core_domain.sql",
        "0003_compatibility_views.sql",
    )


def test_schema_validation_rejects_unsafe_or_missing_migrations(tmp_path: Path) -> None:
    (tmp_path / "0001_bad.sql").write_text("CREATE DATABASE bad;", encoding="utf-8")
    result = validate_schema_directory(tmp_path)
    assert result.passed is False
    assert any("database-level" in issue for issue in result.issues)
