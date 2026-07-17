"""Package a checked-in fixture with a verified SQL Server backup."""

import argparse
import tempfile
from pathlib import Path

from test_pipeline import _documents, _inputs, _metadata

from f1sql.contracts import BuildTarget
from f1sql.pipeline import run_offline_fixture_pipeline


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("backup", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="f1sql-fixture-") as workspace:
        race, results, session, jolpica_raw, fastf1_raw = _inputs(Path(workspace))
        result = run_offline_fixture_pipeline(
            target=BuildTarget(2024, 1),
            race=race,
            results=results,
            session=session,
            output_root=args.output,
            documents=_documents(),
            metadata=_metadata(),
            database_backup=args.backup,
            raw_artifacts={
                "jolpica-season.json": jolpica_raw,
                "fastf1-session.json": fastf1_raw,
            },
        )
    print(result.release.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
