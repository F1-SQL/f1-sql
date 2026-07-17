"""Fetch one settled race and build a verified release candidate directory.

This command deliberately stops before SQL Server backup creation. The
candidate directory contains the deterministic load plan consumed by the
SQL Server integration job and the metadata/assets consumed by the packager.
"""

from __future__ import annotations

import argparse
import subprocess
from datetime import UTC, datetime
from pathlib import Path

from f1sql.config import Settings
from f1sql.contracts import BuildTarget
from f1sql.fingerprint import canonical_json
from f1sql.pipeline import run_offline_fixture_pipeline
from f1sql.sources.fastf1 import FastF1Adapter
from f1sql.sources.jolpica import JolpicaClient
from f1sql.sources.jolpica_models import RaceSummary, Result
from f1sql.sqlserver_mapping import render_load_plan_sql


def _sha(repository: Path) -> str:
    return subprocess.check_output(
        ["git", "-C", str(repository), "rev-parse", "HEAD"], text=True
    ).strip()


def _documents(core_root: Path, race: RaceSummary) -> dict[str, bytes]:
    notes = (
        f"# F1 SQL {race.season}.{race.round}.0\n\n"
        f"Automated release for the {race.race_name} meeting.\n\n"
        "The database backup was built and verified on SQL Server 2019, then "
        "restore-forward tested on SQL Server 2022."
    )
    return {
        name: (core_root / name).read_bytes()
        for name in ("LICENSE-DATA", "NOTICE", "ATTRIBUTION.md")
    } | {"release-notes.md": notes.encode("utf-8")}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("target", type=BuildTarget.parse)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--workspace", type=Path)
    parser.add_argument("--database-repository", type=Path, required=True)
    args = parser.parse_args()

    core_root = Path(__file__).resolve().parents[1]
    settings = Settings.from_env(cwd=args.workspace)
    settings.create_directories()
    now = datetime.now(UTC)
    client = JolpicaClient(settings)
    races, season_collection = client.discover_completed_rounds_with_snapshots(
        args.target.season, now, settling_hours=0
    )
    race = next(
        (item for item in races if item.round == args.target.round),
        None,
    )
    if race is None:
        raise RuntimeError(f"Jolpica did not return settled target {args.target.version}")

    results_collection = client.collect(
        f"{args.target.season}/{args.target.round}/results.json", item_key="Results"
    )
    results = tuple(
        Result.from_api(
            {**item, "season": args.target.season, "round": args.target.round}
        )
        for item in results_collection.items
    )
    fastf1 = FastF1Adapter(settings)
    session = fastf1.load_session(args.target.season, args.target.round, "Race")

    metadata: dict[str, object] = {
        "schema_version": "2.0.0",
        "core_repository_sha": _sha(core_root),
        "database_repository_sha": _sha(args.database_repository),
        "source_versions": {
            "jolpica": "ergast-compatible-v1",
            "fastf1": fastf1.source_version,
        },
        "build_timestamp_utc": now.isoformat().replace("+00:00", "Z"),
    }
    raw_artifacts = {
        "jolpica-season.json": season_collection.snapshots[0].body,
        "jolpica-results.json": results_collection.snapshots[0].body,
        "fastf1-session.json": canonical_json(
            {
                "season": session.season,
                "round": session.round,
                "identifier": session.identifier,
                "source_version": session.source_version,
                "records": session.records,
            }
        ).encode("utf-8"),
    }
    result = run_offline_fixture_pipeline(
        target=args.target,
        race=race,
        results=results,
        session=session,
        output_root=args.output / "unused-release-root",
        documents=_documents(core_root, race),
        metadata=metadata,
        raw_artifacts=raw_artifacts,
        dry_run=True,
    )
    candidate = args.output
    candidate.mkdir(parents=True, exist_ok=True)
    (candidate / "target.txt").write_text(args.target.version + "\n", encoding="utf-8")
    (candidate / "metadata.json").write_text(
        canonical_json(metadata) + "\n", encoding="utf-8"
    )
    (candidate / "normalized.json").write_text(
        result.bundle.to_json() + "\n", encoding="utf-8"
    )
    (candidate / "load-plan.json").write_text(
        result.load_plan.to_json() + "\n", encoding="utf-8"
    )
    (candidate / "load-plan.sql").write_text(
        render_load_plan_sql(result.load_plan) + "\n", encoding="utf-8"
    )
    (candidate / "quality-report.json").write_text(
        result.quality.to_json() + "\n", encoding="utf-8"
    )
    for name, content in {**_documents(core_root, race), **raw_artifacts}.items():
        destination = candidate / (f"raw/{name}" if name.endswith(".json") else name)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
    print(candidate)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
