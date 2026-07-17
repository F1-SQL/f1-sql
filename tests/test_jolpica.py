from collections.abc import Mapping
from datetime import UTC, datetime
from pathlib import Path

from f1sql.cache import ArtifactStore
from f1sql.config import Settings
from f1sql.contracts import BuildTarget
from f1sql.readiness import ReadinessStatus, decide, source_fingerprint
from f1sql.sources.jolpica import JolpicaClient, persist_snapshots
from f1sql.transport import TransportResponse


class FixtureTransport:
    def __init__(self, fixture_dir: Path) -> None:
        self.fixture_dir = fixture_dir
        self.calls: list[Mapping[str, str]] = []

    def request(
        self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
    ) -> TransportResponse:
        self.calls.append(params)
        fixture = self.fixture_dir / f"season-page-{params['offset']}.json"
        return TransportResponse(url, 200, {}, fixture.read_bytes())


class NamedFixtureTransport:
    def __init__(self, fixture_dir: Path) -> None:
        self.fixture_dir = fixture_dir

    def request(
        self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
    ) -> TransportResponse:
        if "status" in url:
            name = "status-data.json"
        elif "standings" in url:
            name = "standings-data.json"
        elif "sprint" in url:
            name = "sprint-data.json"
        elif "qualifying" in url:
            name = "qualifying-data.json"
        elif "laps" in url:
            name = "laps-data.json"
        elif "pitstops" in url:
            name = "pitstops-data.json"
        else:
            name = "race-data.json"
        return TransportResponse(url, 200, {}, (self.fixture_dir / name).read_bytes())


def test_jolpica_pagination_and_snapshots() -> None:
    fixture_dir = Path(__file__).parent / "fixtures" / "jolpica" / "api-v1"
    transport = FixtureTransport(fixture_dir)
    settings = Settings.from_env({"F1SQL_JOLPICA_BASE_URL": "https://example.test"})
    collection = JolpicaClient(settings, transport).collect("2024.json")
    assert len(collection.items) == 2
    assert len(collection.snapshots) == 2
    assert [call["offset"] for call in transport.calls] == ["0", "1"]
    assert collection.snapshots[0].sha256 == collection.snapshots[0].sha256


def test_snapshots_are_persisted_with_provenance(tmp_path: Path) -> None:
    fixture_dir = Path(__file__).parent / "fixtures" / "jolpica" / "api-v1"
    settings = Settings.from_env({"F1SQL_JOLPICA_BASE_URL": "https://example.test"})
    collection = JolpicaClient(settings, FixtureTransport(fixture_dir)).collect("2024.json")
    records = persist_snapshots(collection, ArtifactStore(tmp_path), "jolpica:2024")
    assert len(records) == 2
    assert records[0].source_url == "https://example.test/2024.json"
    assert (tmp_path / records[0].relative_path).exists()


def test_completed_round_discovery_and_sprint_flag() -> None:
    fixture_dir = Path(__file__).parent / "fixtures" / "jolpica" / "api-v1"
    settings = Settings.from_env({"F1SQL_JOLPICA_BASE_URL": "https://example.test"})
    now = datetime(2024, 3, 11, tzinfo=UTC)
    races = JolpicaClient(settings, FixtureTransport(fixture_dir)).discover_completed_rounds(
        2024, now, 24
    )
    assert [race.round for race in races] == [1, 2]
    assert races[0].has_sprint is True


def test_malformed_response_fails_closed(tmp_path: Path) -> None:
    class MalformedTransport:
        def request(
            self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
        ) -> TransportResponse:
            return TransportResponse(url, 200, {}, b"not-json")

    settings = Settings.from_env({"F1SQL_JOLPICA_BASE_URL": "https://example.test"})
    try:
        JolpicaClient(settings, MalformedTransport()).collect("2024.json")
    except ValueError as exc:
        assert "invalid Jolpica response" in str(exc)
    else:
        raise AssertionError("malformed source response was accepted")


def test_readiness_blocks_settling_and_duplicate_releases() -> None:
    fixture_dir = Path(__file__).parent / "fixtures" / "jolpica" / "api-v1"
    settings = Settings.from_env({"F1SQL_JOLPICA_BASE_URL": "https://example.test"})
    race = JolpicaClient(settings, FixtureTransport(fixture_dir)).discover_completed_rounds(
        2024, datetime(2024, 3, 11, tzinfo=UTC), 24
    )[0]
    target = BuildTarget(2024, race.round)
    now = datetime(2024, 3, 2, 16, tzinfo=UTC)
    assert decide(race, target, "abc", {}, now, 24).status is ReadinessStatus.SETTLING
    released = {target.version: "abc"}
    assert (
        decide(race, target, "abc", released, datetime(2024, 3, 11, tzinfo=UTC), 24).status
        is ReadinessStatus.ALREADY_RELEASED
    )
    changed = decide(
        race, target, "changed", released, datetime(2024, 3, 11, tzinfo=UTC), 24
    )
    assert (
        changed.status is ReadinessStatus.FINGERPRINT_CHANGED
    )
    assert source_fingerprint(race) == source_fingerprint(race)


def test_race_data_contracts_cover_results_and_standings() -> None:
    fixture_dir = Path(__file__).parent / "fixtures" / "jolpica" / "api-v1"
    settings = Settings.from_env({"F1SQL_JOLPICA_BASE_URL": "https://example.test"})
    client = JolpicaClient(settings, NamedFixtureTransport(fixture_dir))
    assert len(client.fetch_results(2024, 1)) == 2
    assert client.fetch_results(2024, 1)[0].fastest_lap is not None
    assert len(client.fetch_results(2024, 1, sprint=True)) == 1
    assert len(client.fetch_qualifying(2024, 1)) == 1
    assert client.fetch_laps(2024, 1, 1)[0].driver_id == "max_verstappen"
    assert client.fetch_pit_stops(2024, 1)[0].duration == "22.456"
    assert client.fetch_statuses(2024)[0].name == "Finished"
    assert client.fetch_driver_standings(2024, 1)[0].wins == 1
    assert client.fetch_constructor_standings(2024, 1)[0].constructor.name == "Red Bull"
