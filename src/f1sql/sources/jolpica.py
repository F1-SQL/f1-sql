"""Jolpica/F1 adapter with pagination and raw response snapshots."""

import json
from collections.abc import Mapping
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Any

from ..cache import ArtifactStore
from ..config import Settings
from ..fingerprint import sha256_bytes
from ..provenance import ArtifactRecord
from ..transport import (
    RetryingTransport,
    RetryPolicy,
    Transport,
    TransportResponse,
    UrllibTransport,
)
from .jolpica_models import (
    ConstructorStanding,
    DriverStanding,
    LapTiming,
    PitStop,
    QualifyingResult,
    RaceSummary,
    Result,
    Status,
)


@dataclass(frozen=True, slots=True)
class PageSnapshot:
    url: str
    params: Mapping[str, str]
    fetched_at_utc: str
    sha256: str
    body: bytes


@dataclass(frozen=True, slots=True)
class Collection:
    items: tuple[Mapping[str, Any], ...]
    snapshots: tuple[PageSnapshot, ...]


class JolpicaClient:
    def __init__(self, settings: Settings, transport: Transport | None = None) -> None:
        delegate = transport or UrllibTransport()
        self.settings = settings
        self.transport = RetryingTransport(
            delegate, RetryPolicy(max_retries=settings.max_retries)
        )

    def _request(self, path: str, params: Mapping[str, str]) -> TransportResponse:
        url = f"{self.settings.jolpica_base_url}/{path.lstrip('/')}"
        response = self.transport.request(
            url, params, self.settings.request_timeout_seconds, self.settings.user_agent
        )
        if response.status_code >= 400:
            raise RuntimeError(f"Jolpica request failed with HTTP {response.status_code}: {url}")
        return response

    def collect(
        self,
        path: str,
        params: Mapping[str, str] | None = None,
        item_key: str | None = None,
    ) -> Collection:
        base_params = dict(params or {})
        offset = int(base_params.get("offset", "0"))
        limit = int(base_params.get("limit", "100"))
        items: list[Mapping[str, Any]] = []
        snapshots: list[PageSnapshot] = []
        while True:
            page_params = {**base_params, "limit": str(limit), "offset": str(offset)}
            response = self._request(path, page_params)
            snapshot = PageSnapshot(
                url=response.url,
                params=page_params,
                fetched_at_utc=datetime.now(UTC).isoformat().replace("+00:00", "Z"),
                sha256=sha256_bytes(response.body),
                body=response.body,
            )
            snapshots.append(snapshot)
            try:
                payload = json.loads(response.body)
                mrdata = payload["MRData"]
                table = mrdata.get(
                    "RaceTable",
                    mrdata.get("StandingsTable", mrdata.get("StatusTable", mrdata)),
                )
                if item_key is None:
                    page_items = table.get("Races", table.get("Seasons", []))
                elif item_key in table:
                    page_items = table[item_key]
                else:
                    containers = table.get("Races", table.get("StandingsLists", []))
                    page_items = [
                        child
                        for container in containers
                        for child in container.get(item_key, [])
                    ]
                total = int(mrdata.get("total", len(page_items)))
            except (KeyError, TypeError, ValueError, json.JSONDecodeError) as exc:
                raise ValueError(f"invalid Jolpica response from {response.url}") from exc
            items.extend(page_items)
            if not page_items or len(items) >= total:
                break
            offset += len(page_items)
        return Collection(tuple(items), tuple(snapshots))

    def discover_completed_rounds(
        self, season: int, now: datetime, settling_hours: int | None = None
    ) -> tuple[RaceSummary, ...]:
        races, _ = self.discover_completed_rounds_with_snapshots(season, now, settling_hours)
        return races

    def discover_completed_rounds_with_snapshots(
        self, season: int, now: datetime, settling_hours: int | None = None
    ) -> tuple[tuple[RaceSummary, ...], Collection]:
        collection = self.collect(f"{season}.json")
        settling = self.settings.settling_hours if settling_hours is None else settling_hours
        races = tuple(RaceSummary.from_api(item) for item in collection.items)
        return tuple(race for race in races if race.is_settled(now, settling)), collection

    def fetch_results(self, season: int, round: int, sprint: bool = False) -> tuple[Result, ...]:
        path = f"{season}/{round}/sprint.json" if sprint else f"{season}/{round}/results.json"
        key = "SprintResults" if sprint else "Results"
        return tuple(
            Result.from_api({**item, "season": season, "round": round})
            for item in self.collect(path, item_key=key).items
        )

    def fetch_qualifying(self, season: int, round: int) -> tuple[QualifyingResult, ...]:
        path = f"{season}/{round}/qualifying.json"
        return tuple(
            QualifyingResult.from_api({**item, "season": season, "round": round})
            for item in self.collect(path, item_key="QualifyingResults").items
        )

    def fetch_laps(self, season: int, round: int, lap: int) -> tuple[LapTiming, ...]:
        path = f"{season}/{round}/laps/{lap}.json"
        lap_records = self.collect(path, item_key="Laps").items
        timings = [
            LapTiming.from_api(timing, season, round, int(record["number"]))
            for record in lap_records
            for timing in record.get("Timings", [])
        ]
        return tuple(timings)

    def fetch_pit_stops(self, season: int, round: int) -> tuple[PitStop, ...]:
        path = f"{season}/{round}/pitstops.json"
        return tuple(
            PitStop.from_api(item, season, round)
            for item in self.collect(path, item_key="PitStops").items
        )

    def fetch_statuses(self, season: int) -> tuple[Status, ...]:
        return tuple(
            Status.from_api(item)
            for item in self.collect(f"{season}/status.json", item_key="Status").items
        )

    def fetch_driver_standings(
        self, season: int, round: int | None = None
    ) -> tuple[DriverStanding, ...]:
        path = (
            f"{season}/{round}/driverstandings.json"
            if round
            else f"{season}/driverstandings.json"
        )
        collection = self.collect(path, item_key="DriverStandings")
        return tuple(
            DriverStanding.from_api(item, season, round or 0) for item in collection.items
        )

    def fetch_constructor_standings(
        self, season: int, round: int | None = None
    ) -> tuple[ConstructorStanding, ...]:
        path = (
            f"{season}/{round}/constructorstandings.json"
            if round
            else f"{season}/constructorstandings.json"
        )
        collection = self.collect(path, item_key="ConstructorStandings")
        return tuple(
            ConstructorStanding.from_api(item, season, round or 0) for item in collection.items
        )


def persist_snapshots(
    collection: Collection, store: ArtifactStore, prefix: str = "jolpica"
) -> tuple[ArtifactRecord, ...]:
    """Store immutable response bodies and return manifest-ready provenance."""

    records: list[ArtifactRecord] = []
    for index, snapshot in enumerate(collection.snapshots):
        artifact = store.put(snapshot.body)
        records.append(
            ArtifactRecord(
                artifact_id=f"{prefix}:{index}",
                relative_path=str(artifact.path.relative_to(store.root)),
                sha256=artifact.digest,
                size_bytes=artifact.size_bytes,
                source_url=snapshot.url,
                fetched_at_utc=snapshot.fetched_at_utc,
                media_type="application/json",
            )
        )
    return tuple(records)
