"""Fetch a settled season-to-date and build a verified release candidate directory.

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
from f1sql.pipeline import (
    FixtureInput,
    cumulative_source_fingerprint,
    run_offline_fixture_pipeline,
)
from f1sql.sources.fastf1 import FastF1Adapter
from f1sql.sources.jolpica import JolpicaClient
from f1sql.sources.jolpica_models import RaceSummary, Result
from f1sql.sqlserver_mapping import render_load_plan_sql


def _sha(repository: Path) -> str:
    return subprocess.check_output(
        ["git", "-C", str(repository), "rev-parse", "HEAD"], text=True
    ).strip()


def _documents(
    core_root: Path, race: RaceSummary, included_rounds: int
) -> dict[str, bytes]:
    race_date = race.scheduled_at_utc.strftime("%d/%m/%Y")
    notes = (
        f"Adding the race data from the {race.race_name} {race_date} to the database.\n\n"
        "This is a cumulative roll-up release: all previous race data remains "
        f"available, and round {race.round} was added to the existing dataset. "
        f"The release now contains rounds 1 through {race.round} ({included_rounds} "
        "settled rounds)."
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
    args = parser.parse_args()

    core_root = Path(__file__).resolve().parents[1]
    settings = Settings.from_env(cwd=args.workspace)
    settings.create_directories()
    now = datetime.now(UTC)
    client = JolpicaClient(settings)
    races, season_collection = client.discover_completed_rounds_with_snapshots(
        args.target.season, now, settling_hours=0
    )
    target_race = next(
        (item for item in races if item.round == args.target.round),
        None,
    )
    if target_race is None:
        raise RuntimeError(f"Jolpica did not return settled target {args.target.version}")

    included_races = tuple(item for item in races if item.round <= target_race.round)
    fastf1 = FastF1Adapter(settings)
    fixtures: list[FixtureInput] = []
    raw_artifacts: dict[str, bytes] = {
        f"jolpica-season-{index:03d}.json": snapshot.body
        for index, snapshot in enumerate(season_collection.snapshots)
    }
    for included_race in included_races:
        results_collection = client.collect(
            f"{args.target.season}/{included_race.round}/results.json",
            item_key="Results",
        )
        results = tuple(
            Result.from_api(
                {**item, "season": args.target.season, "round": included_race.round}
            )
            for item in results_collection.items
        )
        session = fastf1.load_session(args.target.season, included_race.round, "Race")
        fixtures.append(FixtureInput(included_race, results, session))
        for index, snapshot in enumerate(results_collection.snapshots):
            raw_artifacts[
                f"jolpica-results-{args.target.season}-{included_race.round:02d}-{index:03d}.json"
            ] = snapshot.body
        raw_artifacts[
            f"fastf1-session-{args.target.season}-{included_race.round:02d}.json"
        ] = canonical_json(
            {
                "season": session.season,
                "round": session.round,
                "identifier": session.identifier,
                "source_version": session.source_version,
                "records": session.records,
            }
        ).encode("utf-8")

    cumulative_fingerprint = cumulative_source_fingerprint(fixtures)

    repository_sha = _sha(core_root)
    metadata: dict[str, object] = {
        "schema_version": "2.0.0",
        "core_repository_sha": repository_sha,
        "database_repository_sha": repository_sha,
        "database_repository": "https://github.com/F1-SQL/f1-sql",
        "database_schema_path": "database/schema/v2",
        "cumulative_through_round": target_race.round,
        "included_rounds": [item.race.round for item in fixtures],
        "source_versions": {
            "jolpica": "ergast-compatible-v1",
            "fastf1": fastf1.source_version,
        },
        "build_timestamp_utc": now.isoformat().replace("+00:00", "Z"),
    }
    result = run_offline_fixture_pipeline(
        target=args.target,
        race=target_race,
        results=fixtures[-1].results,
        session=fixtures[-1].session,
        fixtures=fixtures,
        source_fingerprint_value=cumulative_fingerprint,
        output_root=args.output / "unused-release-root",
        documents=_documents(core_root, target_race, len(fixtures)),
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
    for name, content in {
        **_documents(core_root, target_race, len(fixtures)),
        **raw_artifacts,
    }.items():
        destination = candidate / (f"raw/{name}" if name.endswith(".json") else name)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
    print(candidate)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
