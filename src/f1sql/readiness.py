"""Decisions that prevent duplicate or prematurely published race builds."""

from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum

from .contracts import BuildTarget
from .fingerprint import sha256_json
from .sources.jolpica_models import RaceSummary


class ReadinessStatus(StrEnum):
    READY = "ready"
    SETTLING = "settling"
    ALREADY_RELEASED = "already_released"
    FINGERPRINT_CHANGED = "fingerprint_changed"


@dataclass(frozen=True, slots=True)
class ReadinessDecision:
    target: BuildTarget
    status: ReadinessStatus
    source_fingerprint: str

    @property
    def should_build(self) -> bool:
        return self.status is ReadinessStatus.READY


def source_fingerprint(race: RaceSummary) -> str:
    """Fingerprint the schedule fields that determine a release target."""

    return sha256_json(
        {
            "season": race.season,
            "round": race.round,
            "race_name": race.race_name,
            "circuit": {
                "circuit_id": race.circuit.circuit_id,
                "name": race.circuit.name,
                "locality": race.circuit.locality,
                "country": race.circuit.country,
            },
            "scheduled_at_utc": race.scheduled_at_utc.isoformat().replace("+00:00", "Z"),
            "url": race.url,
            "has_sprint": race.has_sprint,
        }
    )


def cumulative_source_fingerprint(races: Iterable[RaceSummary]) -> str:
    """Fingerprint the ordered season schedule included through a target round."""

    return sha256_json(
        {
            "races": [
                source_fingerprint(race)
                for race in sorted(races, key=lambda item: item.round)
            ]
        }
    )


def decide(
    race: RaceSummary,
    target: BuildTarget,
    source_fingerprint: str,
    released_fingerprints: Mapping[str, str],
    now: datetime,
    settling_hours: int,
) -> ReadinessDecision:
    if not race.is_settled(now, settling_hours):
        status = ReadinessStatus.SETTLING
    else:
        prior = released_fingerprints.get(target.version)
        if prior == source_fingerprint:
            status = ReadinessStatus.ALREADY_RELEASED
        elif prior is not None:
            status = ReadinessStatus.FINGERPRINT_CHANGED
        else:
            status = ReadinessStatus.READY
    return ReadinessDecision(target, status, source_fingerprint)
