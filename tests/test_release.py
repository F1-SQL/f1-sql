from pathlib import Path

import pytest

from f1sql.contracts import BuildTarget
from f1sql.release import (
    ReleaseExistsError,
    ReleasePackager,
    calculate_release_target,
    verify_release,
)


def test_release_bundle_is_verifiable_and_immutable(tmp_path: Path) -> None:
    packager = ReleasePackager(tmp_path / "releases")
    target = BuildTarget(2024, 1)
    plan = packager.build(
        target,
        {
            "database.bak": b"fixture-backup",
            "quality-report.json": b'{"passed":true}\n',
            "LICENSE-DATA": b"CC BY-NC-SA 4.0",
            "NOTICE": b"notice",
            "ATTRIBUTION.md": b"attribution",
            "release-notes.md": b"notes",
        },
        {
            "schema_version": "2.0.0",
            "core_repository_sha": "a" * 40,
            "database_repository_sha": "b" * 40,
            "source_versions": {"fastf1": "3.8.1"},
        },
    )
    assert plan.version == "2024.1.0"
    assets = verify_release(plan.output_dir)
    assert any(asset.name == "manifest.json" for asset in assets)
    assert (plan.output_dir / f"f1-sql-{target.version}.zip").exists()
    with pytest.raises(ReleaseExistsError):
        packager.build(
            target,
            {
                "database.bak": b"changed",
                "quality-report.json": b"{}",
                "LICENSE-DATA": b"license",
                "NOTICE": b"notice",
                "ATTRIBUTION.md": b"attribution",
                "release-notes.md": b"notes",
            },
            {
                "schema_version": "2.0.0",
                "core_repository_sha": "a" * 40,
                "database_repository_sha": "b" * 40,
                "source_versions": {"fastf1": "3.8.1"},
            },
        )


def test_release_dry_run_has_no_publish_side_effect(tmp_path: Path) -> None:
    output = tmp_path / "releases"
    plan = ReleasePackager(output).build(
        BuildTarget(2024, 2),
        {
            "database.bak": b"fixture",
            "quality-report.json": b"{}",
            "LICENSE-DATA": b"license",
            "NOTICE": b"notice",
            "ATTRIBUTION.md": b"attribution",
            "release-notes.md": b"notes",
        },
        {
            "schema_version": "2.0.0",
            "core_repository_sha": "a" * 40,
            "database_repository_sha": "b" * 40,
            "source_versions": {"fastf1": "3.8.1"},
        },
        dry_run=True,
    )
    assert plan.dry_run is True
    assert not plan.output_dir.exists()


def test_release_revision_is_immutable_and_correction_aware() -> None:
    assert calculate_release_target(2024, 1, "new", {}).version == "2024.1.0"
    released = {"2024.1.0": "old", "2024.1.1": "older"}
    assert calculate_release_target(2024, 1, "new", released).version == "2024.1.2"
    assert calculate_release_target(2024, 1, "old", released) is None
