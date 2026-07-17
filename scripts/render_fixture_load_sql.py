"""Render the checked-in representative fixture as executable v2 T-SQL."""

import argparse
import tempfile
from pathlib import Path

from test_pipeline import _inputs

from f1sql.load_plan import build_load_plan
from f1sql.pipeline import normalize_fixture
from f1sql.sqlserver_mapping import render_load_plan_sql


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="f1sql-fixture-") as workspace:
        race, results, session, _, _ = _inputs(Path(workspace))
    bundle = normalize_fixture(race, results, session)
    args.output.write_text(render_load_plan_sql(build_load_plan(bundle)), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
