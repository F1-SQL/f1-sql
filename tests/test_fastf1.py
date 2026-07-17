import json
from pathlib import Path
from typing import Any

import pytest

from f1sql.config import Settings
from f1sql.sources.fastf1 import FastF1Adapter, FastF1EventNotFound


class FakeSession:
    def __init__(self, values: dict[str, Any], delayed: bool = False) -> None:
        self.__dict__.update(values)
        self.delayed = delayed

    def load(self) -> None:
        if self.delayed:
            raise RuntimeError("timing data has not settled")


class FakeProvider:
    __version__ = "3.8.1"

    def __init__(self, schedule: list[dict[str, Any]], session: FakeSession) -> None:
        self.schedule = schedule
        self.session = session
        self.cache_path: Path | None = None

    def enable_cache(self, path: Path) -> None:
        self.cache_path = path

    def get_event_schedule(self, season: int) -> list[dict[str, Any]]:
        return self.schedule

    def get_session(self, season: int, event: int, identifier: str) -> FakeSession:
        if identifier == "Missing":
            raise LookupError("session does not exist")
        return self.session


def _fixtures() -> tuple[list[dict[str, Any]], dict[str, Any]]:
    root = Path(__file__).parent / "fixtures" / "fastf1" / "v1"
    schedule = json.loads((root / "schedule-2024.json").read_text(encoding="utf-8"))
    session = json.loads((root / "session-2024-1.json").read_text(encoding="utf-8"))
    return schedule, session


def test_fastf1_schedule_cache_and_rich_session(tmp_path: Path) -> None:
    schedule, values = _fixtures()
    provider = FakeProvider(schedule, FakeSession(values))
    settings = Settings.from_env({}, cwd=tmp_path)
    adapter = FastF1Adapter(settings, provider)
    event = adapter.discover_event(2024, 1, "Bahrain Grand Prix")
    assert event.session_names == ("Practice 1", "Sprint", "Qualifying", "Race")
    assert provider.cache_path == settings.fastf1_cache_dir
    snapshot = adapter.load_session(2024, 1, "Race")
    assert snapshot.status == "complete"
    assert snapshot.coverage == "rich"
    assert set(snapshot.available) == {
        "laps",
        "pit_stops",
        "race_control",
        "results",
        "sectors",
        "speeds",
        "stints",
        "telemetry",
        "track_status",
        "tyres",
        "weather",
    }
    assert snapshot.records["sectors"][0]["Sector1Time"] == "0:00:30.000"
    assert snapshot.records["speeds"][0]["SpeedFL"] == 320.0
    assert snapshot.records["stints"][0]["Compound"] == "SOFT"
    assert snapshot.records["pit_stops"][0]["PitInTime"] == "0:20:00.000"
    assert snapshot.record_fingerprint == adapter.load_session(2024, 1, "Race").record_fingerprint
    assert snapshot.source_version == "3.8.1"


def test_fastf1_missing_delayed_cancelled_and_pre2018_paths(tmp_path: Path) -> None:
    schedule, values = _fixtures()
    settings = Settings.from_env({}, cwd=tmp_path)
    adapter = FastF1Adapter(settings, FakeProvider(schedule, FakeSession(values)))
    assert adapter.load_session(2024, 2, "Race").status == "cancelled"
    assert adapter.load_session(2024, 1, "Missing").status == "unavailable"
    delayed = FastF1Adapter(settings, FakeProvider(schedule, FakeSession(values, delayed=True)))
    assert delayed.load_session(2024, 1, "Race").status == "delayed"
    legacy = FastF1Adapter(settings, FakeProvider(schedule, FakeSession(values)))
    legacy_snapshot = legacy.load_session(2017, 1, "Race")
    assert legacy_snapshot.coverage == "historical_limited"
    assert legacy_snapshot.available == ("results",)


def test_fastf1_event_matching_fails_closed(tmp_path: Path) -> None:
    schedule, values = _fixtures()
    adapter = FastF1Adapter(
        Settings.from_env({}, cwd=tmp_path), FakeProvider(schedule, FakeSession(values))
    )
    with pytest.raises(FastF1EventNotFound):
        adapter.discover_event(2024, 1, "Wrong Name")
