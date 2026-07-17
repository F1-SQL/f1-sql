# Legacy-to-v2 mapping boundary

The legacy scripts are reference material only. Historical imports must map
into the source-neutral v2 grain below and must retain a provenance record for
every admitted source artifact.

| Legacy concept | v2 table(s) | Migration rule |
| --- | --- | --- |
| `seasons` | `f1sql.Season` | One row per season; reject values before 1950. |
| `circuits`, `locations`, `countries` | `f1sql.Circuit` | Preserve provider identity and bounded coordinates. |
| `drivers` | `f1sql.Driver`, `f1sql.ExternalIdentifier` | Resolve by provider ID; reject ambiguous labels. |
| `teams` | `f1sql.Constructor`, `f1sql.ExternalIdentifier` | Treat constructor identity as source-neutral. |
| `meetings` | `f1sql.Meeting` | Key by season/round and normalize schedule timestamps to UTC. |
| `sessions` | `f1sql.Session` | Preserve explicit status; do not manufacture unavailable sessions. |
| `driverSession`, `driverMeeting` | `f1sql.Participant` | Materialize event/session participation from admitted results. |
| `results` | `f1sql.Result` | Preserve classified position text, points, laps, and status. |
| `laps`, `stints`, `pitStops` | corresponding v2 fact tables | Import only when source coverage and units are documented. |
| `intervals`, `teamRadio` | none in v2 | Deferred scope; do not import into a substitute shape. |

Each batch must record its target cursor, source fingerprints, row counts,
known gaps, corrections, and the monorepo SHA and schema path. A mapping
decision that cannot preserve the original meaning remains excluded until an
explicit schema decision is approved.
