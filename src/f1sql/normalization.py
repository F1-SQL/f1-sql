"""Deterministic, provider-neutral records and reconciliation evidence."""

import re
from collections.abc import Mapping, Sequence
from contextlib import suppress
from dataclasses import asdict, dataclass, field
from datetime import UTC, datetime
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation
from enum import StrEnum
from typing import Any, cast

from .fingerprint import canonical_json, sha256_json
from .sources.jolpica_models import RaceSummary, Result


def _jsonable(value: Any) -> Any:
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, datetime):
        return value.isoformat().replace("+00:00", "Z")
    if isinstance(value, Mapping):
        return {str(key): _jsonable(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [_jsonable(item) for item in value]
    return value


class DiscrepancySeverity(StrEnum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"


@dataclass(frozen=True, slots=True)
class Discrepancy:
    domain: str
    field: str
    severity: DiscrepancySeverity
    message: str
    evidence: Mapping[str, Any]


@dataclass(frozen=True, slots=True)
class NormalizedDriver:
    key: str
    given_name: str
    family_name: str
    external_ids: Mapping[str, str]
    provider_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedConstructor:
    key: str
    name: str
    external_ids: Mapping[str, str]
    provider_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedCircuit:
    key: str
    name: str
    locality: str | None
    country: str | None
    latitude: float | None
    longitude: float | None
    external_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedMeeting:
    season: int
    round: int
    name: str
    scheduled_at_utc: datetime
    circuit_key: str
    external_ids: Mapping[str, str]
    has_sprint: bool


@dataclass(frozen=True, slots=True)
class NormalizedResult:
    season: int
    round: int
    session_type: str
    driver_key: str
    constructor_key: str
    driver_number: int | None
    position: int | None
    position_text: str | None
    points: Decimal
    laps: int | None
    duration_ms: int | None
    status: str | None
    external_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedSession:
    season: int
    round: int
    session_type: str
    start_utc: datetime | None
    end_utc: datetime | None
    provider_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedLap:
    season: int
    round: int
    session_type: str
    driver_key: str
    lap_number: int
    lap_time_ms: int | None
    sector_times_ms: tuple[int | None, int | None, int | None]
    speeds_kph: Mapping[str, Decimal]
    external_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedStint:
    season: int
    round: int
    session_type: str
    driver_key: str
    stint_number: int
    compound: str | None
    start_lap: int | None
    end_lap: int | None
    fresh_tyre: bool | None


@dataclass(frozen=True, slots=True)
class NormalizedPitStop:
    season: int
    round: int
    session_type: str
    driver_key: str
    stop_number: int
    lap_number: int | None
    duration_ms: int | None
    external_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizedWeather:
    season: int
    round: int
    session_type: str
    observed_at_utc: datetime
    values: Mapping[str, Decimal | None]


@dataclass(frozen=True, slots=True)
class NormalizedRaceControl:
    season: int
    round: int
    session_type: str
    message_at_utc: datetime | None
    message: str
    category: str | None
    provider_ids: Mapping[str, str]


@dataclass(frozen=True, slots=True)
class NormalizationBundle:
    drivers: tuple[NormalizedDriver, ...] = ()
    constructors: tuple[NormalizedConstructor, ...] = ()
    circuits: tuple[NormalizedCircuit, ...] = ()
    meetings: tuple[NormalizedMeeting, ...] = ()
    sessions: tuple[NormalizedSession, ...] = ()
    results: tuple[NormalizedResult, ...] = ()
    laps: tuple[NormalizedLap, ...] = ()
    stints: tuple[NormalizedStint, ...] = ()
    pit_stops: tuple[NormalizedPitStop, ...] = ()
    weather: tuple[NormalizedWeather, ...] = ()
    race_control: tuple[NormalizedRaceControl, ...] = ()
    discrepancies: tuple[Discrepancy, ...] = ()

    def to_dict(self) -> dict[str, Any]:
        return cast(dict[str, Any], _jsonable(asdict(self)))

    def fingerprint(self) -> str:
        return sha256_json(self.to_dict())

    def to_json(self) -> str:
        return canonical_json(self.to_dict())


def parse_utc(value: str | datetime, assume_utc: bool = False) -> datetime:
    parsed = (
        value
        if isinstance(value, datetime)
        else datetime.fromisoformat(value.replace("Z", "+00:00"))
    )
    if parsed.tzinfo is None:
        if not assume_utc:
            raise ValueError("timestamp must include a timezone offset")
        parsed = parsed.replace(tzinfo=UTC)
    return parsed.astimezone(UTC)


def duration_ms(value: str | None) -> int | None:
    """Convert F1 ``H:MM:SS.sss`` or ``M:SS.sss`` values to integer milliseconds."""

    if value is None or value == "":
        return None
    parts = value.split(":")
    if len(parts) not in (2, 3):
        raise ValueError(f"invalid duration: {value}")
    try:
        numbers = [Decimal(part) for part in parts]
    except InvalidOperation as exc:
        raise ValueError(f"invalid duration: {value}") from exc
    if len(numbers) == 2:
        minutes, seconds = numbers
        total_seconds = minutes * 60 + seconds
    else:
        hours, minutes, seconds = numbers
        total_seconds = hours * 3600 + minutes * 60 + seconds
    return int((total_seconds * 1000).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def _slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.casefold()).strip("-")


class IdentityAmbiguity(ValueError):
    pass


class IdentityResolver:
    """Map provider identities to stable keys while rejecting ambiguous labels."""

    def __init__(self) -> None:
        self._by_source: dict[tuple[str, str, str], str] = {}
        self._source_labels: dict[tuple[str, str, str], str] = {}
        self._by_label: dict[tuple[str, str], set[str]] = {}

    def resolve(self, domain: str, source: str, external_id: str, label: str) -> str:
        source_key = (domain, source, external_id)
        if source_key in self._by_source:
            if self._source_labels[source_key] != _slug(label):
                raise IdentityAmbiguity(
                    f"source identity changed label for {domain}:{external_id}"
                )
            return self._by_source[source_key]
        label_key = (domain, _slug(label))
        candidates = self._by_label.setdefault(label_key, set())
        if len(candidates) > 1:
            raise IdentityAmbiguity(f"ambiguous {domain} label: {label}")
        key = next(iter(candidates), f"{domain}:{_slug(label)}")
        candidates.add(key)
        self._by_source[source_key] = key
        self._source_labels[source_key] = _slug(label)
        return key


@dataclass(frozen=True, slots=True)
class SourcePolicy:
    """Primary-source choices from ADR 0002, overridable for tests or future ADRs."""

    primary_sources: Mapping[str, str] = field(
        default_factory=lambda: {
            "meeting": "jolpica",
            "result": "jolpica",
            "standing": "jolpica",
            "session": "fastf1",
            "lap": "fastf1",
            "weather": "fastf1",
        }
    )

    def primary(self, domain: str, values: Mapping[str, Any]) -> tuple[str, Any]:
        if not values:
            raise ValueError("at least one source value is required")
        source = self.primary_sources.get(domain, next(iter(values)))
        if source not in values:
            raise ValueError(f"primary source {source!r} has no value for {domain}")
        return source, values[source]


def normalize_race(race: RaceSummary, resolver: IdentityResolver) -> NormalizedMeeting:
    circuit_key = resolver.resolve("circuit", "jolpica", race.circuit.circuit_id, race.circuit.name)
    return NormalizedMeeting(
        season=race.season,
        round=race.round,
        name=race.race_name,
        scheduled_at_utc=parse_utc(race.scheduled_at_utc),
        circuit_key=circuit_key,
        external_ids={"jolpica:circuit": race.circuit.circuit_id},
        has_sprint=race.has_sprint,
    )


def normalize_result(
    result: Result, resolver: IdentityResolver, session_type: str = "race"
) -> tuple[NormalizedResult, tuple[Discrepancy, ...]]:
    driver_key = resolver.resolve(
        "driver", "jolpica", result.driver.driver_id, result.driver.family_name
    )
    constructor_key = resolver.resolve(
        "constructor", "jolpica", result.constructor.constructor_id, result.constructor.name
    )
    discrepancies: list[Discrepancy] = []
    if result.position is None and result.position_text is None:
        discrepancies.append(
            Discrepancy(
                domain="result",
                field="position",
                severity=DiscrepancySeverity.WARNING,
                message="result has no numeric or textual classification",
                evidence={"driver_id": result.driver.driver_id},
            )
        )
    return (
        NormalizedResult(
            season=result.season,
            round=result.round,
            session_type=session_type,
            driver_key=driver_key,
            constructor_key=constructor_key,
            driver_number=result.number,
            position=result.position,
            position_text=result.position_text,
            points=Decimal(str(result.points)),
            laps=result.laps,
            duration_ms=duration_ms(result.time),
            status=result.status,
            external_ids={
                "jolpica:driver": result.driver.driver_id,
                "jolpica:constructor": result.constructor.constructor_id,
            },
        ),
        tuple(discrepancies),
    )


def reconcile_scalar(
    domain: str,
    field: str,
    values: Mapping[str, Any],
    tolerance: Decimal | None = None,
    primary_source: str | None = None,
) -> tuple[Any, tuple[Discrepancy, ...]]:
    """Select the configured first source and emit evidence for disagreements."""

    if not values:
        raise ValueError("at least one source value is required")
    selected_source = primary_source or next(iter(values))
    if selected_source not in values:
        raise ValueError(f"primary source {selected_source!r} has no value")
    selected = values[selected_source]
    discrepancies: list[Discrepancy] = []
    for source, value in values.items():
        if source == selected_source:
            continue
        differs = value != selected
        if tolerance is not None:
            with suppress(InvalidOperation):
                differs = abs(Decimal(str(value)) - Decimal(str(selected))) > tolerance
        if differs:
            discrepancies.append(
                Discrepancy(
                    domain=domain,
                    field=field,
                    severity=DiscrepancySeverity.WARNING,
                    message="source values disagree; primary source selected",
                    evidence={"selected_source": selected_source, "values": dict(values)},
                )
            )
    return selected, tuple(discrepancies)


def reconcile_result_sets(
    primary: Sequence[NormalizedResult], secondary: Sequence[NormalizedResult]
) -> tuple[tuple[NormalizedResult, ...], tuple[Discrepancy, ...]]:
    """Compare classified results, winners, and lap counts using primary records."""

    secondary_by_key = {
        (item.season, item.round, item.session_type, item.driver_key): item
        for item in secondary
    }
    discrepancies: list[Discrepancy] = []
    primary_winners = {
        item.driver_key for item in primary if item.position == 1
    }
    secondary_winners = {
        item.driver_key for item in secondary if item.position == 1
    }
    if primary_winners != secondary_winners:
        discrepancies.append(
            Discrepancy(
                "result",
                "winner",
                DiscrepancySeverity.ERROR,
                "sources disagree on the classified winner",
                {"primary": sorted(primary_winners), "secondary": sorted(secondary_winners)},
            )
        )
    for item in primary:
        key = (item.season, item.round, item.session_type, item.driver_key)
        counterpart = secondary_by_key.get(key)
        if counterpart is None:
            discrepancies.append(
                Discrepancy(
                    "result",
                    "classification",
                    DiscrepancySeverity.WARNING,
                    "primary classified result is absent from secondary source",
                    {"key": key},
                )
            )
        elif (
            item.laps is not None
            and counterpart.laps is not None
            and item.laps != counterpart.laps
        ):
            discrepancies.append(
                Discrepancy(
                    "result",
                    "laps",
                    DiscrepancySeverity.WARNING,
                    "sources disagree on completed lap count",
                    {"key": key, "primary": item.laps, "secondary": counterpart.laps},
                )
            )
    return tuple(primary), tuple(discrepancies)


def reconcile_schedule_and_participants(
    primary_meetings: Sequence[NormalizedMeeting],
    secondary_meetings: Sequence[NormalizedMeeting],
    primary_results: Sequence[NormalizedResult],
    secondary_results: Sequence[NormalizedResult],
) -> tuple[tuple[NormalizedMeeting, ...], tuple[Discrepancy, ...]]:
    """Reconcile schedule keys, circuit identities, and participant coverage."""

    discrepancies: list[Discrepancy] = []
    secondary_meetings_by_key = {
        (meeting.season, meeting.round): meeting for meeting in secondary_meetings
    }
    for meeting in primary_meetings:
        key = (meeting.season, meeting.round)
        counterpart = secondary_meetings_by_key.get(key)
        if counterpart is None:
            discrepancies.append(
                Discrepancy(
                    "meeting",
                    "schedule",
                    DiscrepancySeverity.WARNING,
                    "primary meeting is absent from secondary schedule",
                    {"key": key},
                )
            )
        elif meeting.circuit_key != counterpart.circuit_key:
            discrepancies.append(
                Discrepancy(
                    "meeting",
                    "circuit",
                    DiscrepancySeverity.ERROR,
                    "sources disagree on meeting circuit",
                    {
                        "key": key,
                        "primary": meeting.circuit_key,
                        "secondary": counterpart.circuit_key,
                    },
                )
            )
    primary_participants = {
        (item.season, item.round, item.session_type, item.driver_key) for item in primary_results
    }
    secondary_participants = {
        (item.season, item.round, item.session_type, item.driver_key) for item in secondary_results
    }
    for missing in sorted(primary_participants - secondary_participants):
        discrepancies.append(
            Discrepancy(
                "participant",
                "coverage",
                DiscrepancySeverity.WARNING,
                "primary participant is absent from secondary source",
                {"key": missing},
            )
        )
    _, result_discrepancies = reconcile_result_sets(primary_results, secondary_results)
    return tuple(primary_meetings), tuple(discrepancies) + result_discrepancies
