"""Static validation for the versioned SQL Server schema scripts."""

import re
from dataclasses import dataclass
from pathlib import Path

REQUIRED_TABLES = (
    "SchemaHistory",
    "BuildRun",
    "SourceArtifact",
    "ExternalIdentifier",
    "DataRelease",
    "Season",
    "Circuit",
    "Driver",
    "Constructor",
    "Meeting",
    "Session",
    "Participant",
    "Result",
    "Lap",
    "Stint",
    "PitStop",
    "Weather",
    "RaceControl",
)
_SCRIPT_NAME = re.compile(r"^(\d{4})_[a-z0-9_-]+\.sql$")


@dataclass(frozen=True, slots=True)
class SchemaValidation:
    scripts: tuple[str, ...]
    issues: tuple[str, ...]

    @property
    def passed(self) -> bool:
        return not self.issues


def validate_schema_directory(path: Path) -> SchemaValidation:
    scripts = tuple(sorted(item for item in path.glob("*.sql") if item.is_file()))
    issues: list[str] = []
    versions: list[int] = []
    combined = ""
    for script in scripts:
        match = _SCRIPT_NAME.fullmatch(script.name)
        if match is None:
            issues.append(f"invalid migration filename: {script.name}")
            continue
        versions.append(int(match.group(1)))
        text = script.read_text(encoding="utf-8")
        combined += f"\n{text}"
        if re.search(r"\b(USE|CREATE|ALTER)\s+DATABASE\b", text, re.IGNORECASE):
            issues.append(f"database-level statement in {script.name}")
        if "IF OBJECT_ID" not in text and "IF SCHEMA_ID" not in text:
            issues.append(f"migration is not guarded/idempotent: {script.name}")
    if versions != list(range(1, len(versions) + 1)):
        issues.append(f"migration versions are not contiguous: {versions}")
    for table in REQUIRED_TABLES:
        if not re.search(rf"CREATE\s+TABLE\s+f1sql\.{table}\b", combined, re.IGNORECASE):
            issues.append(f"required table is missing: f1sql.{table}")
    return SchemaValidation(tuple(script.name for script in scripts), tuple(issues))
