import json
import subprocess
import sys
from pathlib import Path

from f1sql.release import verify_release


def test_package_candidate_release_attaches_backup(tmp_path: Path) -> None:
    candidate = tmp_path / "candidate"
    candidate.mkdir()
    (candidate / "target.txt").write_text("2024.1.0\n", encoding="utf-8")
    (candidate / "metadata.json").write_text(
        json.dumps(
            {
                "schema_version": "2.0.0",
                "core_repository_sha": "a" * 40,
                "database_repository_sha": "b" * 40,
                "source_versions": {"jolpica": "test", "fastf1": "test"},
            }
        ),
        encoding="utf-8",
    )
    for name in ("LICENSE-DATA", "NOTICE", "ATTRIBUTION.md", "release-notes.md"):
        (candidate / name).write_text(name, encoding="utf-8")
    (candidate / "quality-report.json").write_text('{"passed":true}\n', encoding="utf-8")
    backup = tmp_path / "database.bak"
    backup.write_bytes(b"verified backup")
    output = tmp_path / "release-output"
    script = Path(__file__).parents[1] / "scripts" / "package_candidate_release.py"
    subprocess.run(
        [sys.executable, str(script), str(candidate), str(backup), str(output)], check=True
    )
    assets = {item.name for item in verify_release(output / "2024.1.0")}
    assert "database.bak" in assets
