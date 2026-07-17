"""Run and source provenance records written alongside every build."""

import json
from collections.abc import Mapping
from dataclasses import asdict, dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any
from uuid import uuid4

from .contracts import BuildTarget
from .fingerprint import canonical_json


def _utc_now() -> str:
    return datetime.now(UTC).isoformat().replace("+00:00", "Z")


@dataclass(frozen=True, slots=True)
class ArtifactRecord:
    artifact_id: str
    relative_path: str
    sha256: str
    size_bytes: int
    source_url: str | None = None
    fetched_at_utc: str | None = None
    media_type: str | None = None


@dataclass(frozen=True, slots=True)
class RunManifest:
    manifest_version: int
    run_id: str
    created_at_utc: str
    target: BuildTarget
    config_fingerprint: str
    source_repository: str
    database_repository: str | None = None
    database_repository_sha: str | None = None
    database_schema_path: str = "database/schema/v2"
    source_versions: Mapping[str, str] = field(default_factory=dict)
    stages: tuple[str, ...] = ()
    artifacts: tuple[ArtifactRecord, ...] = ()

    @classmethod
    def create(
        cls,
        target: BuildTarget,
        config_fingerprint: str,
        source_repository: str,
        database_repository: str | None = None,
        database_repository_sha: str | None = None,
        database_schema_path: str = "database/schema/v2",
        source_versions: Mapping[str, str] | None = None,
    ) -> "RunManifest":
        return cls(
            manifest_version=1,
            run_id=str(uuid4()),
            created_at_utc=_utc_now(),
            target=target,
            config_fingerprint=config_fingerprint,
            source_repository=source_repository,
            database_repository=database_repository,
            database_repository_sha=database_repository_sha,
            database_schema_path=database_schema_path,
            source_versions=dict(source_versions or {}),
        )

    def to_dict(self) -> dict[str, Any]:
        value = asdict(self)
        value["target"] = asdict(self.target)
        return value

    def write(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(canonical_json(self.to_dict()) + "\n", encoding="utf-8")

    @classmethod
    def read(cls, path: Path) -> "RunManifest":
        value = json.loads(path.read_text(encoding="utf-8"))
        target = BuildTarget(**value.pop("target"))
        value["target"] = target
        value["stages"] = tuple(value.get("stages", ()))
        value["artifacts"] = tuple(ArtifactRecord(**item) for item in value.get("artifacts", ()))
        return cls(**value)
