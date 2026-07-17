"""Typed models for the stable, low-volume Jolpica/F1 API entities."""

from collections.abc import Mapping
from dataclasses import dataclass
from datetime import UTC, date, datetime, time
from typing import Any


def _text(value: Any) -> str | None:
    return str(value) if value is not None else None


def _integer(value: Any) -> int | None:
    return int(value) if value is not None else None


def _number(value: Any) -> float | None:
    return float(value) if value is not None else None


@dataclass(frozen=True, slots=True)
class Season:
    year: int
    url: str | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "Season":
        return cls(year=int(value["season"]), url=_text(value.get("url")))


@dataclass(frozen=True, slots=True)
class Circuit:
    circuit_id: str
    name: str
    locality: str | None
    country: str | None
    lat: float | None
    long: float | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "Circuit":
        location = value.get("Location", {})
        return cls(
            circuit_id=str(value["circuitId"]),
            name=str(value["circuitName"]),
            locality=_text(location.get("locality")),
            country=_text(location.get("country")),
            lat=float(location["lat"]) if location.get("lat") is not None else None,
            long=float(location["long"]) if location.get("long") is not None else None,
        )


@dataclass(frozen=True, slots=True)
class Driver:
    driver_id: str
    given_name: str
    family_name: str
    nationality: str | None
    permanent_number: int | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "Driver":
        number = value.get("permanentNumber")
        return cls(
            driver_id=str(value["driverId"]),
            given_name=str(value["givenName"]),
            family_name=str(value["familyName"]),
            nationality=_text(value.get("nationality")),
            permanent_number=int(number) if number is not None else None,
        )


@dataclass(frozen=True, slots=True)
class Constructor:
    constructor_id: str
    name: str
    nationality: str | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "Constructor":
        return cls(
            constructor_id=str(value["constructorId"]),
            name=str(value["name"]),
            nationality=_text(value.get("nationality")),
        )


@dataclass(frozen=True, slots=True)
class FastestLap:
    lap: int
    rank: int | None
    time: str | None
    average_speed: float | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "FastestLap":
        speed = value.get("AverageSpeed", {}).get("speed")
        return cls(
            lap=int(value["lap"]),
            rank=_integer(value.get("rank")),
            time=_text(value.get("Time", {}).get("time")),
            average_speed=_number(speed),
        )


@dataclass(frozen=True, slots=True)
class Result:
    season: int
    round: int
    number: int | None
    position: int | None
    position_text: str | None
    points: float
    driver: Driver
    constructor: Constructor
    grid: int | None
    laps: int | None
    status: str | None
    time: str | None
    fastest_lap: FastestLap | None
    time_millis: int | None = None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "Result":
        fastest = value.get("FastestLap")
        time_value = value.get("Time") or {}
        return cls(
            season=int(value["season"]),
            round=int(value["round"]),
            number=_integer(value.get("number")),
            position=_integer(value.get("position")),
            position_text=_text(value.get("positionText")),
            points=float(value.get("points", 0)),
            driver=Driver.from_api(value["Driver"]),
            constructor=Constructor.from_api(value["Constructor"]),
            grid=_integer(value.get("grid")),
            laps=_integer(value.get("laps")),
            status=_text(value.get("status")),
            time=_text(time_value.get("time")),
            fastest_lap=FastestLap.from_api(fastest) if fastest else None,
            time_millis=_integer(time_value.get("millis", time_value.get("milliseconds"))),
        )


@dataclass(frozen=True, slots=True)
class QualifyingResult:
    season: int
    round: int
    number: int | None
    position: int | None
    driver: Driver
    constructor: Constructor
    q1: str | None
    q2: str | None
    q3: str | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "QualifyingResult":
        return cls(
            season=int(value["season"]),
            round=int(value["round"]),
            number=_integer(value.get("number")),
            position=_integer(value.get("position")),
            driver=Driver.from_api(value["Driver"]),
            constructor=Constructor.from_api(value["Constructor"]),
            q1=_text(value.get("Q1")),
            q2=_text(value.get("Q2")),
            q3=_text(value.get("Q3")),
        )


@dataclass(frozen=True, slots=True)
class LapTiming:
    season: int
    round: int
    lap: int
    driver_id: str
    position: int | None
    time: str | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any], season: int, round: int, lap: int) -> "LapTiming":
        return cls(
            season=season,
            round=round,
            lap=lap,
            driver_id=str(value["driverId"]),
            position=_integer(value.get("position")),
            time=_text(value.get("time")),
        )


@dataclass(frozen=True, slots=True)
class PitStop:
    season: int
    round: int
    driver_id: str
    stop: int
    lap: int
    time: str | None
    duration: str | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any], season: int, round: int) -> "PitStop":
        return cls(
            season=season,
            round=round,
            driver_id=str(value["driverId"]),
            stop=int(value["stop"]),
            lap=int(value["lap"]),
            time=_text(value.get("time")),
            duration=_text(value.get("duration")),
        )


@dataclass(frozen=True, slots=True)
class Status:
    status_id: int
    name: str
    count: int | None

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "Status":
        return cls(
            status_id=int(value["statusId"]),
            name=str(value["status"]),
            count=_integer(value.get("count")),
        )


@dataclass(frozen=True, slots=True)
class DriverStanding:
    season: int
    round: int
    position: int | None
    position_text: str | None
    points: float
    wins: int
    driver: Driver
    constructors: tuple[Constructor, ...]

    @classmethod
    def from_api(cls, value: Mapping[str, Any], season: int, round: int) -> "DriverStanding":
        return cls(
            season=season,
            round=round,
            position=_integer(value.get("position")),
            position_text=_text(value.get("positionText")),
            points=float(value.get("points", 0)),
            wins=int(value.get("wins", 0)),
            driver=Driver.from_api(value["Driver"]),
            constructors=tuple(
                Constructor.from_api(item) for item in value.get("Constructors", [])
            ),
        )


@dataclass(frozen=True, slots=True)
class ConstructorStanding:
    season: int
    round: int
    position: int | None
    position_text: str | None
    points: float
    wins: int
    constructor: Constructor

    @classmethod
    def from_api(cls, value: Mapping[str, Any], season: int, round: int) -> "ConstructorStanding":
        return cls(
            season=season,
            round=round,
            position=_integer(value.get("position")),
            position_text=_text(value.get("positionText")),
            points=float(value.get("points", 0)),
            wins=int(value.get("wins", 0)),
            constructor=Constructor.from_api(value["Constructor"]),
        )


@dataclass(frozen=True, slots=True)
class RaceSummary:
    season: int
    round: int
    race_name: str
    circuit: Circuit
    scheduled_at_utc: datetime
    url: str | None
    has_sprint: bool

    @classmethod
    def from_api(cls, value: Mapping[str, Any]) -> "RaceSummary":
        date_value = date.fromisoformat(str(value["date"]))
        time_value = value.get("time", "00:00:00Z").replace("Z", "+00:00")
        scheduled = datetime.combine(date_value, time.fromisoformat(time_value))
        if scheduled.tzinfo is None:
            scheduled = scheduled.replace(tzinfo=UTC)
        return cls(
            season=int(value["season"]),
            round=int(value["round"]),
            race_name=str(value["raceName"]),
            circuit=Circuit.from_api(value["Circuit"]),
            scheduled_at_utc=scheduled.astimezone(UTC),
            url=_text(value.get("url")),
            has_sprint="Sprint" in value,
        )

    def is_settled(self, now: datetime, settling_hours: int) -> bool:
        if now.tzinfo is None:
            raise ValueError("now must be timezone-aware")
        elapsed = (now.astimezone(UTC) - self.scheduled_at_utc).total_seconds()
        return elapsed >= settling_hours * 3600
