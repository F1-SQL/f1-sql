# Release policy

## Versioning

Database releases use `season.round.revision`:

* `2026.12.0` is the first release after round 12 of the 2026 season.
* `2026.12.1` is a correction using changed source data or build logic.

Each release is cumulative for its season. A `2026.12.0` release contains
rounds 1 through 12, while the version identifies round 12 as the newest
available round. Earlier releases remain immutable snapshots.

An existing release is immutable. Corrections always receive a new tag and
release; assets are never silently replaced.

## Automatic release readiness

The scheduled detector identifies a completed, unreleased championship round
from source data rather than a repository-maintained calendar. The heavy build
runs only when:

1. Jolpica-F1 has the event, official race results, and required participants.
2. FastF1 can load the required completed event sessions.
3. The configured settling period after the race has elapsed.
4. The cumulative source fingerprint differs from the latest release for that
   target round.

If data is unavailable, the workflow exits without failure and retries at the
next scheduled run. A manual workflow accepts season, round, revision, and
dry-run inputs for recovery and controlled corrections.

## Release gates

The following must pass before publishing:

* unit, source-contract, typing, and transformation tests;
* schema creation and migration tests;
* primary key, foreign key, uniqueness, orphan, and required-value checks;
* expected event/session/participant coverage checks;
* Jolpica-F1 and FastF1 result reconciliation;
* SQL Server `DBCC CHECKDB` and backup verification; and
* restore into a fresh supported SQL Server instance followed by smoke queries.

## SQL Server support

The initial v2 baseline is a compressed SQL Server 2019 backup. It is validated
on SQL Server 2019 and restored forward on SQL Server 2022. SQL Server 2016 is
not a v2 target. Support for additional versions must be explicit and tested.

## Required assets

Each public release contains:

* the compressed SQL Server backup;
* `manifest.json` with source fingerprints, retrieval times, dependency
  versions, the monorepo commit, schema path/version, and row counts;
* `quality-report.json`;
* `checksums.sha256`;
* `LICENSE-DATA`, `NOTICE`, and `ATTRIBUTION.md`; and
* concise release notes describing coverage and known limitations.

Normalized source snapshots should be retained in durable storage or as a
release asset when size and upstream terms permit. A transient CI artifact is
not sufficient evidence for a reproducible public release.
