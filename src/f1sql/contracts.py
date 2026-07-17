"""Small, source-neutral contracts shared by every pipeline stage."""

from dataclasses import dataclass
from enum import StrEnum


class PipelineStage(StrEnum):
    """Stages are deliberately finite so manifests can be audited."""

    DISCOVER = "discover"
    INGEST = "ingest"
    NORMALIZE = "normalize"
    LOAD = "load"
    VERIFY = "verify"
    PACKAGE = "package"


@dataclass(frozen=True, order=True, slots=True)
class BuildTarget:
    """A release target identified by season, round, and correction revision."""

    season: int
    round: int
    revision: int = 0

    def __post_init__(self) -> None:
        if self.season < 1950:
            raise ValueError("season must be 1950 or later")
        if self.round < 1:
            raise ValueError("round must be positive")
        if self.revision < 0:
            raise ValueError("revision cannot be negative")

    @property
    def version(self) -> str:
        return f"{self.season}.{self.round}.{self.revision}"

    @classmethod
    def parse(cls, value: str) -> "BuildTarget":
        parts = value.split(".")
        if len(parts) not in (2, 3):
            raise ValueError("target must be SEASON.ROUND or SEASON.ROUND.REVISION")
        try:
            numbers = [int(part) for part in parts]
        except ValueError as exc:
            raise ValueError("target components must be integers") from exc
        if len(numbers) == 2:
            return cls(numbers[0], numbers[1])
        return cls(numbers[0], numbers[1], numbers[2])
