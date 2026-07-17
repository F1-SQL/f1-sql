import json
from dataclasses import replace
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import pytest
from test_jolpica import FixtureTransport, NamedFixtureTransport

from f1sql.config import Settings
from f1sql.contracts import BuildTarget
from f1sql.pipeline import PipelineGateError, persist_fastf1_snapshot, run_offline_fixture_pipeline
from f1sql.release import verify_release
from f1sql.sources.fastf1 import FastF1Adapter, SessionSnapshot
from f1sql.sources.jolpica import JolpicaClient
from f1sql.sources.jolpica_models import RaceSummary, Result


class FixtureSession:
    def __init__(self, values: dict[str, Any]) -> None:
        self.__dict__.update(values)

    def load(self) -> None:
        return None


class FixtureProvider:
    __version__ = "3.8.1"

    def __init__(self, schedule: list[dict[str, Any]], values: dict[str, Any]) -> None:
        self.schedule = schedule
        self.values = values

    def get_event_schedule(self, season: int) -> list[dict[str, Any]]:
        return self.schedule

    def get_session(self, season: int, event: int, identifier: str) -> FixtureSession:
        return FixtureSession(self.values)


def _inputs(
    tmp_path: Path,
) -> tuple[RaceSummary, tuple[Result, ...], SessionSnapshot, bytes, bytes]:
    fixture_root = Path(__file__).parent / "fixtures"
    jolpica_root = fixture_root / "jolpica" / "api-v1"
    settings = Settings.from_env({}, cwd=tmp_path)
    race_client = JolpicaClient(settings, FixtureTransport(jolpica_root))
    races, collection = race_client.discover_completed_rounds_with_snapshots(
        2024, datetime(2024, 3, 11, tzinfo=UTC), 24
    )
    results = JolpicaClient(settings, NamedFixtureTransport(jolpica_root)).fetch_results(2024, 1)
    fastf1_root = fixture_root / "fastf1" / "v1"
    schedule = json.loads((fastf1_root / "schedule-2024.json").read_text(encoding="utf-8"))
    values = json.loads((fastf1_root / "session-2024-1.json").read_text(encoding="utf-8"))
    snapshot = FastF1Adapter(settings, FixtureProvider(schedule, values)).load_session(
        2024, 1, "Race"
    )
    return (
        races[0],
        results,
        snapshot,
        collection.snapshots[0].body,
        json.dumps(snapshot.records, sort_keys=True).encode("utf-8"),
    )


def _documents() -> dict[str, bytes]:
    return {
        "LICENSE-DATA": b"CC BY-NC-SA 4.0",
        "NOTICE": b"Fixture notice",
        "ATTRIBUTION.md": b"Fixture attribution",
        "release-notes.md": b"Offline fixture release",
    }


def _metadata() -> dict[str, object]:
    return {
        "schema_version": "2.0.0",
        "core_repository_sha": "a" * 40,
        "database_repository_sha": "b" * 40,
        "source_versions": {"jolpica": "api-v1", "fastf1": "3.8.1"},
    }


def test_offline_fixture_pipeline_reaches_a_verifiable_release(tmp_path: Path) -> None:
    race, results, session, jolpica_raw, fastf1_raw = _inputs(tmp_path)
    result = run_offline_fixture_pipeline(
        target=BuildTarget(2024, 1),
        race=race,
        results=results,
        session=session,
        output_root=tmp_path / "releases",
        documents=_documents(),
        metadata=_metadata(),
        raw_artifacts={"jolpica-season.json": jolpica_raw, "fastf1-session.json": fastf1_raw},
    )
    assert result.quality.passed is True
    assert result.load_plan.fingerprint()
    assert (result.release.output_dir / "normalized.json").exists()
    assert any(
        asset.name == "load-plan.json" for asset in verify_release(result.release.output_dir)
    )


def test_offline_fixture_pipeline_blocks_bad_data_before_packaging(tmp_path: Path) -> None:
    race, results, session, _, _ = _inputs(tmp_path)
    with pytest.raises(PipelineGateError, match="result.key_unique"):
        run_offline_fixture_pipeline(
            target=BuildTarget(2024, 1),
            race=race,
            results=results + (results[0],),
            session=session,
            output_root=tmp_path / "releases",
            documents=_documents(),
            metadata=_metadata(),
        )
    assert not (tmp_path / "releases" / "2024.1.0").exists()


def test_offline_fixture_pipeline_blocks_cross_source_winner_conflict(tmp_path: Path) -> None:
    race, results, session, _, _ = _inputs(tmp_path)
    conflicting_records = {
        **session.records,
        "results": ({"DriverNumber": "1", "Position": 2, "Points": 25},),
    }
    conflicting = replace(session, records=conflicting_records)
    with pytest.raises(PipelineGateError):
        run_offline_fixture_pipeline(
            target=BuildTarget(2024, 1),
            race=race,
            results=results,
            session=conflicting,
            output_root=tmp_path / "releases",
            documents=_documents(),
            metadata=_metadata(),
        )


def test_offline_pipeline_allows_missing_optional_fastf1_fields(tmp_path: Path) -> None:
    race, results, session, _, _ = _inputs(tmp_path)
    sparse = replace(
        session,
        records={"results": session.records["results"]},
        missing=("laps", "stints", "pit_stops", "weather", "race_control"),
    )

    result = run_offline_fixture_pipeline(
        target=BuildTarget(2024, 1),
        race=race,
        results=results,
        session=sparse,
        output_root=tmp_path / "releases",
        documents=_documents(),
        metadata=_metadata(),
    )

    assert result.quality.passed is True
    assert {gap.domain for gap in result.quality.coverage_gaps} == {
        "lap",
        "stint",
        "pit_stop",
        "weather",
        "race_control",
    }


def test_fastf1_snapshot_persistence_is_content_addressed(tmp_path: Path) -> None:
    _, _, session, _, _ = _inputs(tmp_path)
    from f1sql.cache import ArtifactStore

    first = persist_fastf1_snapshot(session, ArtifactStore(tmp_path / "raw"))
    second = persist_fastf1_snapshot(session, ArtifactStore(tmp_path / "raw"))
    assert first == second


def test_offline_pipeline_can_include_a_verified_database_backup(tmp_path: Path) -> None:
    race, results, session, _, _ = _inputs(tmp_path)
    backup = tmp_path / "fixture.bak"
    backup.write_bytes(b"verified-sql-server-backup")
    result = run_offline_fixture_pipeline(
        target=BuildTarget(2024, 2),
        race=race,
        results=results,
        session=session,
        output_root=tmp_path / "releases",
        documents=_documents(),
        metadata=_metadata(),
        database_backup=backup,
    )
    assets = {asset.name for asset in verify_release(result.release.output_dir)}
    assert "database.bak" in assets
