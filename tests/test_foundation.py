from pathlib import Path

import pytest

from f1sql.cache import ArtifactStore
from f1sql.config import Settings
from f1sql.contracts import BuildTarget
from f1sql.fingerprint import canonical_json, sha256_json
from f1sql.provenance import RunManifest


def test_build_target_round_trip() -> None:
    target = BuildTarget.parse("2026.3.1")
    assert target.version == "2026.3.1"
    assert BuildTarget.parse("2026.3").version == "2026.3.0"
    with pytest.raises(ValueError):
        BuildTarget.parse("2026")


def test_canonical_json_is_stable() -> None:
    assert canonical_json({"b": 1, "a": [True, "é"]}) == '{"a":[true,"é"],"b":1}'
    assert sha256_json({"a": 1}) == sha256_json({"a": 1})


def test_settings_defaults_and_validation(tmp_path: Path) -> None:
    settings = Settings.from_env({}, cwd=tmp_path)
    assert settings.raw_dir == tmp_path / ".f1sql" / "raw"
    with pytest.raises(ValueError):
        Settings.from_env({"F1SQL_MAX_RETRIES": "0"}, cwd=tmp_path)


def test_artifact_store_is_content_addressed(tmp_path: Path) -> None:
    store = ArtifactStore(tmp_path)
    first = store.put(b"hello")
    second = store.put(b"hello")
    assert first == second
    assert store.read(first.digest) == b"hello"
    first.path.write_bytes(b"tampered")
    with pytest.raises(IOError):
        store.read(first.digest)


def test_manifest_round_trip(tmp_path: Path) -> None:
    manifest = RunManifest.create(
        BuildTarget(2026, 3),
        "config-sha",
        "core-sha",
        database_repository_sha="b" * 40,
        source_versions={"fastf1": "3.8.1"},
    )
    path = tmp_path / "manifest.json"
    manifest.write(path)
    loaded = RunManifest.read(path)
    assert loaded.target == manifest.target
    assert loaded.run_id == manifest.run_id
    assert loaded.source_versions == {"fastf1": "3.8.1"}
    assert loaded.database_repository_sha == "b" * 40
    assert loaded.database_schema_path == "database/schema/v2"
