"""Attach a verified SQL Server backup and package a production candidate."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from f1sql.contracts import BuildTarget
from f1sql.release import ReleasePackager, verify_release


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("candidate", type=Path)
    parser.add_argument("backup", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    target = BuildTarget.parse((args.candidate / "target.txt").read_text().strip())
    metadata = json.loads((args.candidate / "metadata.json").read_text(encoding="utf-8"))
    assets: dict[str, Path] = {"database.bak": args.backup}
    excluded = {"metadata.json", "target.txt"}
    for path in args.candidate.rglob("*"):
        if not path.is_file() or path.name in excluded:
            continue
        assets[str(path.relative_to(args.candidate))] = path
    release = ReleasePackager(args.output).build(target, assets, metadata)
    verify_release(release.output_dir)
    print(release.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
