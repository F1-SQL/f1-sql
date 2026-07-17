"""Deterministic, locally verifiable release bundle construction."""

import json
import re
import shutil
from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

from .contracts import BuildTarget
from .fingerprint import canonical_json, sha256_bytes


@dataclass(frozen=True, slots=True)
class ReleaseAsset:
    name: str
    sha256: str
    size_bytes: int


@dataclass(frozen=True, slots=True)
class ReleasePlan:
    version: str
    output_dir: Path
    assets: tuple[ReleaseAsset, ...]
    dry_run: bool


class ReleaseExistsError(FileExistsError):
    pass


def calculate_release_target(
    season: int,
    round: int,
    source_fingerprint: str,
    released_fingerprints: Mapping[str, str],
) -> BuildTarget | None:
    """Return the next immutable revision, or ``None`` for an identical release."""

    prefix = f"{season}.{round}."
    revisions = []
    for version, fingerprint in released_fingerprints.items():
        if not version.startswith(prefix):
            continue
        try:
            revision = int(version[len(prefix) :])
        except ValueError:
            continue
        if fingerprint == source_fingerprint:
            return None
        revisions.append(revision)
    return BuildTarget(season, round, max(revisions, default=-1) + 1)


class ReleasePackager:
    """Build releases without replacing an existing version."""

    required_documents = frozenset(
        {"LICENSE-DATA", "NOTICE", "ATTRIBUTION.md", "release-notes.md", "quality-report.json"}
    )
    required_metadata = frozenset(
        {"schema_version", "core_repository_sha", "database_repository_sha", "source_versions"}
    )

    def __init__(self, output_root: Path) -> None:
        self.output_root = output_root

    def plan(
        self,
        target: BuildTarget,
        assets: Mapping[str, bytes | Path],
        dry_run: bool = False,
    ) -> ReleasePlan:
        missing = self.required_documents.difference(assets)
        if missing:
            raise ValueError(f"release is missing required documents: {sorted(missing)}")
        version_dir = self.output_root / target.version
        if version_dir.exists() and not dry_run:
            raise ReleaseExistsError(f"release already exists: {target.version}")
        planned = tuple(
            ReleaseAsset(name, sha256_bytes(_read_asset(value)), len(_read_asset(value)))
            for name, value in sorted(assets.items())
        )
        return ReleasePlan(target.version, version_dir, planned, dry_run)

    def build(
        self,
        target: BuildTarget,
        assets: Mapping[str, bytes | Path],
        metadata: Mapping[str, object],
        dry_run: bool = False,
    ) -> ReleasePlan:
        missing_metadata = self.required_metadata.difference(metadata)
        if missing_metadata:
            raise ValueError(f"release metadata is incomplete: {sorted(missing_metadata)}")
        for key in ("core_repository_sha", "database_repository_sha"):
            value = metadata[key]
            if not isinstance(value, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", value):
                raise ValueError(f"invalid repository SHA in metadata: {key}")
        if not isinstance(metadata["source_versions"], Mapping):
            raise ValueError("source_versions metadata must be an object")
        plan = self.plan(target, assets, dry_run=dry_run)
        if dry_run:
            return plan
        self.output_root.mkdir(parents=True, exist_ok=True)
        with TemporaryDirectory(prefix=f"f1sql-{target.version}-", dir=self.output_root) as temp:
            staging = Path(temp)
            for name, value in sorted(assets.items()):
                _safe_asset_name(name)
                destination = staging / name
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(_read_asset(value))
            manifest = {
                **metadata,
                "manifest_version": 1,
                "release_version": target.version,
                "assets": {
                    asset.name: {
                        "sha256": asset.sha256,
                        "size_bytes": asset.size_bytes,
                    }
                    for asset in plan.assets
                },
            }
            (staging / "manifest.json").write_text(
                canonical_json(manifest) + "\n", encoding="utf-8"
            )
            quality = staging / "quality-report.json"
            if not quality.exists():
                quality.write_text(canonical_json({"passed": True}) + "\n", encoding="utf-8")
            checksum_lines = []
            for path in sorted(staging.rglob("*")):
                if path.is_file() and path.name != "checksums.sha256":
                    checksum_lines.append(
                        f"{sha256_bytes(path.read_bytes())}  {path.relative_to(staging)}"
                    )
            (staging / "checksums.sha256").write_text(
                "\n".join(checksum_lines) + "\n", encoding="utf-8"
            )
            archive = staging / f"f1-sql-{target.version}.zip"
            _write_deterministic_zip(staging, archive)
            if plan.output_dir.exists():
                raise ReleaseExistsError(f"release appeared during build: {target.version}")
            shutil.move(str(staging), str(plan.output_dir))
        return plan


def _read_asset(value: bytes | Path) -> bytes:
    return value if isinstance(value, bytes) else value.read_bytes()


def _safe_asset_name(name: str) -> None:
    path = Path(name)
    if path.is_absolute() or ".." in path.parts or not name:
        raise ValueError(f"unsafe release asset path: {name!r}")


def _write_deterministic_zip(staging: Path, archive: Path) -> None:
    with ZipFile(archive, "w", compression=ZIP_DEFLATED, compresslevel=9) as bundle:
        for path in sorted(staging.rglob("*")):
            if path == archive or not path.is_file():
                continue
            relative = path.relative_to(staging).as_posix()
            info = ZipInfo(relative, date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_DEFLATED
            bundle.writestr(info, path.read_bytes())


def verify_release(path: Path) -> tuple[ReleaseAsset, ...]:
    manifest = json.loads((path / "manifest.json").read_text(encoding="utf-8"))
    required = {
        "release_version",
        "schema_version",
        "core_repository_sha",
        "database_repository_sha",
        "source_versions",
        "assets",
    }
    if not required.issubset(manifest) or not isinstance(manifest.get("assets"), dict):
        raise ValueError("invalid release manifest")
    checksum_file = path / "checksums.sha256"
    assets: list[ReleaseAsset] = []
    for line in checksum_file.read_text(encoding="utf-8").splitlines():
        digest, name = line.split("  ", 1)
        content = (path / name).read_bytes()
        actual = sha256_bytes(content)
        if actual != digest:
            raise ValueError(f"checksum mismatch: {name}")
        assets.append(ReleaseAsset(name, actual, len(content)))
    for asset in assets:
        declared = manifest["assets"].get(asset.name)
        if declared is not None and declared.get("sha256") != asset.sha256:
            raise ValueError(f"manifest mismatch: {asset.name}")
    archives = list(path.glob("f1-sql-*.zip"))
    if archives:
        with ZipFile(archives[0]) as archive:
            names = set(archive.namelist())
        if "manifest.json" not in names or "checksums.sha256" not in names:
            raise ValueError("release archive is missing required metadata")
    return tuple(assets)
