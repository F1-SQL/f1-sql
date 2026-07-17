# Historical coverage policy

Backfill is bounded by source capability and provenance, not by the presence of
legacy files. A missing value remains missing; no historical value is inferred
from a later source.

| Domain | Jolpica/F1 API | FastF1 | v2 policy |
| --- | --- | --- | --- |
| seasons, meetings, circuits | 1950–present where API returns a record | schedule support varies | use Jolpica as primary |
| drivers, constructors, results | 1950–present where API returns a record | session results 2018–present | use Jolpica as primary |
| qualifying, sprints, standings | source/provider coverage dependent | session-dependent | preserve explicit gaps |
| laps, sectors, speeds, tyres, stints | low-level API records where available | 2018–present rich sessions | FastF1 primary for rich session facts |
| pit stops, weather, race control | endpoint/session dependent | 2018–present session-dependent | publish coverage flags |
| telemetry, continuous intervals, team radio | out of v2 scope | out of v2 scope | deferred by ADR 0002 |

Each backfill batch must record season/round bounds, source fingerprints, row
counts, known gaps, and the exact monorepo commit and schema path. Legacy
archives remain quarantined until their source terms and provenance are audited
item by item.

The `f1sql.backfill.BackfillLedger` persists those receipts atomically. A
same-fingerprint receipt is idempotent; a changed receipt must explicitly use
`correction_of`, preventing silent replacement of historical results.
