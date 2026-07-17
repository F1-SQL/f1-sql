"""Command-line entry point for the v2 pipeline foundation."""

import argparse
import json
import sys
from datetime import UTC, datetime
from pathlib import Path

from . import __version__
from .cache import ArtifactStore
from .config import Settings
from .contracts import BuildTarget
from .fingerprint import sha256_json
from .readiness import ReadinessStatus, decide, source_fingerprint
from .sources.jolpica import JolpicaClient, persist_snapshots


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="f1sql", description="F1 SQL v2 pipeline")
    parser.add_argument("--version", action="version", version=__version__)
    commands = parser.add_subparsers(dest="command", required=True)
    init = commands.add_parser("init", help="create local pipeline directories")
    init.add_argument("target", type=BuildTarget.parse, help="SEASON.ROUND[.REVISION]")
    init.add_argument("--workspace", type=Path)
    fingerprint = commands.add_parser("fingerprint", help="fingerprint a JSON value")
    fingerprint.add_argument("value", help="JSON value")
    readiness = commands.add_parser(
        "detect", help="discover settled rounds and emit a release-readiness decision"
    )
    readiness.add_argument("--season", type=int, help="season to inspect (defaults to UTC year)")
    readiness.add_argument("--now", help="UTC timestamp override for deterministic runs")
    readiness.add_argument("--workspace", type=Path)
    readiness.add_argument(
        "--github-output", type=Path, help="write ready/target/status outputs for Actions"
    )
    return parser


def _released_fingerprints(output_dir: Path) -> dict[str, str]:
    released: dict[str, str] = {}
    if not output_dir.exists():
        return released
    for manifest_path in output_dir.glob("*/manifest.json"):
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        fingerprint = manifest.get("source_fingerprint")
        version = manifest.get("release_version")
        if isinstance(version, str) and isinstance(fingerprint, str):
            released[version] = fingerprint
    return released


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.command == "fingerprint":
        try:
            print(sha256_json(json.loads(args.value)))
        except (json.JSONDecodeError, ValueError) as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 2
        return 0
    settings = Settings.from_env(cwd=getattr(args, "workspace", None))
    settings.create_directories()
    if args.command == "detect":
        try:
            season = args.season or datetime.now(UTC).year
            now = (
                datetime.fromisoformat(args.now.replace("Z", "+00:00"))
                if args.now
                else datetime.now(UTC)
            )
            if now.tzinfo is None:
                raise ValueError("--now must include a timezone")
            released = _released_fingerprints(settings.output_dir)
            decisions = []
            client = JolpicaClient(settings)
            races, collection = client.discover_completed_rounds_with_snapshots(season, now)
            persist_snapshots(collection, ArtifactStore(settings.raw_dir), f"jolpica:{season}")
            for race in races:
                target = BuildTarget(season, race.round)
                fingerprint = source_fingerprint(race)
                decision = decide(race, target, fingerprint, released, now, settings.settling_hours)
                decisions.append(
                    {
                        "target": target.version,
                        "status": decision.status.value,
                        "source_fingerprint": fingerprint,
                    }
                )
            ready = next(
                (item for item in decisions if item["status"] == ReadinessStatus.READY), None
            )
            result = {
                "season": season,
                "ready": ready is not None,
                "target": ready,
                "decisions": decisions,
            }
            print(json.dumps(result, sort_keys=True))
            if args.github_output:
                args.github_output.write_text(
                    f"ready={'true' if ready else 'false'}\n"
                    f"target={ready['target'] if ready else ''}\n"
                    f"status={ready['status'] if ready else 'none'}\n",
                    encoding="utf-8",
                )
        except (OSError, ValueError, RuntimeError) as exc:
            print(f"error: readiness detection failed: {exc}", file=sys.stderr)
            return 2
        return 0
    store = ArtifactStore(settings.raw_dir)
    print(
        json.dumps(
            {
                "target": args.target.version,
                "raw_dir": str(store.root),
                "output_dir": str(settings.output_dir),
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
