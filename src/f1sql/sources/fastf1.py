"""Optional FastF1 adapter with explicit cache, coverage, and missing-data semantics."""

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from datetime import UTC, date, datetime, time
from importlib import import_module
from importlib.metadata import PackageNotFoundError
from importlib.metadata import version as package_version
from math import isnan
from typing import Any, Protocol

from ..config import Settings
from ..fingerprint import sha256_json


class FastF1Provider(Protocol):
    def get_event_schedule(self, season: int) -> Any: ...

    def get_session(self, season: int, event: int, identifier: str) -> Any: ...


class FastF1Error(RuntimeError):
    """Base error for adapter contract failures."""


class FastF1EventNotFound(FastF1Error):
    pass


@dataclass(frozen=True, slots=True)
class EventRef:
    season: int
    round: int
    name: str
    official_name: str | None
    country: str | None
    location: str | None
    event_date_utc: datetime | None
    session_names: tuple[str, ...]
    cancelled: bool


@dataclass(frozen=True, slots=True)
class SessionSnapshot:
    season: int
    round: int
    identifier: str
    source_version: str
    cache_dir: str
    coverage: str
    status: str
    available: tuple[str, ...]
    missing: tuple[str, ...]
    errors: tuple[str, ...]
    records: Mapping[str, tuple[Mapping[str, Any], ...]]
    record_fingerprint: str
    cache_fingerprint: str


def _value(row: Mapping[str, Any], *keys: str) -> Any:
    for key in keys:
        if key in row:
            return row[key]
    return None


def _rows(value: Any) -> list[Mapping[str, Any]]:
    if value is None:
        return []
    if hasattr(value, "to_dict"):
        converted = value.to_dict("records")
        return [item for item in converted if isinstance(item, Mapping)]
    if isinstance(value, Mapping):
        return [value]
    if isinstance(value, Iterable) and not isinstance(value, (str, bytes)):
        return [item for item in value if isinstance(item, Mapping)]
    return []


def _jsonable(value: Any) -> Any:
    if value is None or isinstance(value, (str, int, float, bool)):
        if isinstance(value, float) and isnan(value):
            return None
        return value
    if isinstance(value, (datetime, date, time)):
        return value.isoformat()
    if isinstance(value, Mapping):
        return {str(key): _jsonable(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [_jsonable(item) for item in value]
    return str(value)


def _utc_datetime(value: Any) -> datetime | None:
    if value is None:
        return None
    if hasattr(value, "to_pydatetime"):
        value = value.to_pydatetime()
    if isinstance(value, date) and not isinstance(value, datetime):
        value = datetime.combine(value, time.min)
    if isinstance(value, datetime):
        return (value.replace(tzinfo=UTC) if value.tzinfo is None else value).astimezone(UTC)
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except ValueError:
        return None
    return (parsed.replace(tzinfo=UTC) if parsed.tzinfo is None else parsed).astimezone(UTC)


def _schedule_rows(schedule: Any) -> list[Mapping[str, Any]]:
    if hasattr(schedule, "to_dict"):
        records = schedule.to_dict("records")
        return [item for item in records if isinstance(item, Mapping)]
    return [item for item in schedule if isinstance(item, Mapping)]


class FastF1Adapter:
    """Adapter around FastF1, injectable with a fake provider for offline tests."""

    _data_fields = {
        "results": ("results",),
        "laps": ("laps",),
        "sectors": ("sectors",),
        "speeds": ("speeds",),
        "tyres": ("tyres",),
        "stints": ("stints",),
        "pit_stops": ("pit_stops", "pitstops"),
        "weather": ("weather",),
        "track_status": ("track_status",),
        "race_control": ("race_control_messages", "race_control"),
        "telemetry": ("car_data", "telemetry"),
    }

    def __init__(self, settings: Settings, provider: FastF1Provider | None = None) -> None:
        self.settings = settings
        self.provider: Any
        settings.fastf1_cache_dir.mkdir(parents=True, exist_ok=True)
        if provider is None:
            module = import_module("fastf1")
            self.provider = module
            self.source_version = self._resolve_version(module)
            cache = getattr(module, "Cache", None)
            if cache is not None:
                cache.enable_cache(str(settings.fastf1_cache_dir))
        else:
            self.provider = provider
            self.source_version = self._resolve_version(provider)
            enable_cache = getattr(provider, "enable_cache", None)
            if callable(enable_cache):
                enable_cache(settings.fastf1_cache_dir)

    @staticmethod
    def _resolve_version(provider: Any) -> str:
        explicit = getattr(provider, "__version__", None)
        if explicit:
            return str(explicit)
        try:
            return package_version("fastf1")
        except PackageNotFoundError as exc:
            raise FastF1Error(
                "FastF1 is not installed and no provider version was supplied"
            ) from exc

    def discover_event(
        self, season: int, round: int, expected_name: str | None = None
    ) -> EventRef:
        matches = []
        for row in _schedule_rows(self.provider.get_event_schedule(season)):
            row_round = _value(row, "RoundNumber", "round", "Round")
            if row_round is None or int(row_round) != round:
                continue
            name = str(_value(row, "EventName", "name") or "")
            if expected_name is not None and name.casefold() != expected_name.casefold():
                continue
            matches.append(row)
        if len(matches) != 1:
            raise FastF1EventNotFound(
                f"expected exactly one FastF1 event for {season}.{round}, found {len(matches)}"
            )
        row = matches[0]
        names = tuple(
            str(row[key])
            for key in ("Session1", "Session2", "Session3", "Session4", "Session5")
            if row.get(key) not in (None, "") and str(row[key]).lower() != "nan"
        )
        cancelled = bool(_value(row, "Cancelled", "cancelled") or False)
        return EventRef(
            season=season,
            round=round,
            name=str(_value(row, "EventName", "name") or ""),
            official_name=_value(row, "OfficialEventName", "official_name"),
            country=_value(row, "Country", "country"),
            location=_value(row, "Location", "location"),
            event_date_utc=_utc_datetime(_value(row, "EventDate", "event_date")),
            session_names=names,
            cancelled=cancelled,
        )

    def load_session(self, season: int, round: int, identifier: str) -> SessionSnapshot:
        event = self.discover_event(season, round)
        coverage = "rich" if season >= 2018 else "historical_limited"
        if event.cancelled:
            return self._snapshot(season, round, identifier, coverage, "cancelled", (), (), ())
        if event.session_names and not any(
            identifier.casefold() == name.casefold() for name in event.session_names
        ):
            return self._snapshot(
                season,
                round,
                identifier,
                coverage,
                "unavailable",
                (),
                self._data_fields,
                (f"session '{identifier}' is not present in the event schedule",),
            )
        try:
            session = self.provider.get_session(season, round, identifier)
        except Exception as exc:  # provider-specific missing-session exception
            return self._snapshot(
                season,
                round,
                identifier,
                coverage,
                "unavailable",
                (),
                self._data_fields,
                (str(exc),),
            )
        try:
            session.load()
        except Exception as exc:  # delayed or partially published session
            return self._snapshot(
                season,
                round,
                identifier,
                coverage,
                "delayed",
                (),
                self._data_fields,
                (str(exc),),
            )
        available: dict[str, tuple[Mapping[str, Any], ...]] = {}
        missing: list[str] = []
        for name, attributes in self._data_fields.items():
            value = next(
                (
                    getattr(session, attribute, None)
                    for attribute in attributes
                    if hasattr(session, attribute)
                ),
                None,
            )
            records = tuple(_jsonable(item) for item in _rows(value))
            if records:
                available[name] = records
            else:
                missing.append(name)
        derived = _derive_lap_records(available.get("laps", ()))
        for name, records in derived.items():
            if records:
                available[name] = records
                if name in missing:
                    missing.remove(name)
        status = "complete" if "results" in available else "partial"
        if season < 2018:
            available = {"results": available["results"]} if "results" in available else {}
            missing = [name for name in self._data_fields if name != "results"]
        return self._snapshot(
            season, round, identifier, coverage, status, available, tuple(missing), ()
        )

    def _snapshot(
        self,
        season: int,
        round: int,
        identifier: str,
        coverage: str,
        status: str,
        records: Mapping[str, tuple[Mapping[str, Any], ...]] | tuple[Any, ...],
        missing: Iterable[str],
        errors: Iterable[str],
    ) -> SessionSnapshot:
        normalized = dict(records) if isinstance(records, Mapping) else {}
        record_fingerprint = sha256_json(
            {"season": season, "round": round, "identifier": identifier, "records": normalized}
        )
        cache_fingerprint = sha256_json(
            {"cache_dir": str(self.settings.fastf1_cache_dir), "record": record_fingerprint}
        )
        return SessionSnapshot(
            season=season,
            round=round,
            identifier=identifier,
            source_version=self.source_version,
            cache_dir=str(self.settings.fastf1_cache_dir),
            coverage=coverage,
            status=status,
            available=tuple(sorted(normalized)),
            missing=tuple(sorted(missing)),
            errors=tuple(errors),
            records=normalized,
            record_fingerprint=record_fingerprint,
            cache_fingerprint=cache_fingerprint,
        )


def _derive_lap_records(
    laps: tuple[Mapping[str, Any], ...]
) -> dict[str, tuple[Mapping[str, Any], ...]]:
    """Extract stable sector, speed, tyre, and stint records from FastF1 laps."""

    sectors: list[Mapping[str, Any]] = []
    speeds: list[Mapping[str, Any]] = []
    tyres: list[Mapping[str, Any]] = []
    pit_stops: list[Mapping[str, Any]] = []
    stints: dict[tuple[Any, Any], dict[str, Any]] = {}
    for lap in laps:
        identity = {
            key: lap[key]
            for key in ("DriverNumber", "Driver", "LapNumber")
            if key in lap
        }
        sector = _lap_projection(
            identity, lap, ("Sector1Time", "Sector2Time", "Sector3Time")
        )
        speed = _lap_projection(identity, lap, ("SpeedI1", "SpeedI2", "SpeedFL", "SpeedST"))
        tyre = _lap_projection(identity, lap, ("Compound", "TyreLife", "FreshTyre"))
        pit = _lap_projection(identity, lap, ("PitInTime", "PitOutTime"))
        if len(sector) > len(identity):
            sectors.append(sector)
        if len(speed) > len(identity):
            speeds.append(speed)
        if len(tyre) > len(identity):
            tyres.append(tyre)
        if len(pit) > len(identity):
            pit_stops.append(pit)
        if "Stint" in lap:
            stint_key = (lap.get("DriverNumber", lap.get("Driver")), lap["Stint"])
            record = stints.setdefault(
                stint_key,
                {
                    "DriverNumber": lap.get("DriverNumber"),
                    "Driver": lap.get("Driver"),
                    "Stint": lap["Stint"],
                    "Compound": lap.get("Compound"),
                    "StartLap": lap.get("LapNumber"),
                    "EndLap": lap.get("LapNumber"),
                    "FreshTyre": lap.get("FreshTyre"),
                },
            )
            record["EndLap"] = lap.get("LapNumber", record["EndLap"])
    return {
        "sectors": tuple(sectors),
        "speeds": tuple(speeds),
        "tyres": tuple(tyres),
        "stints": tuple(stints.values()),
        "pit_stops": tuple(pit_stops),
    }


def _lap_projection(
    identity: Mapping[str, Any], lap: Mapping[str, Any], fields: tuple[str, ...]
) -> dict[str, Any]:
    return {
        **identity,
        **{field: lap[field] for field in fields if field in lap},
    }
