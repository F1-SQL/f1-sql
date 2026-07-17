# Schema v2 principles

* Status: Accepted
* Date: 2026-07-17

## Scope

Schema v2 is the target relational contract for the Jolpica-F1 and FastF1
rebuild. The exported legacy `Tables/` definitions and corrective `scripts/`
remain reference material until v2 replaces the public release pipeline.

## Rules

1. Every table is created by versioned DDL before data is loaded. Import-time
   schema inference is prohibited.
2. Primary keys, foreign keys, uniqueness constraints, nullability, and useful
   indexes are part of the schema and are tested in the built database.
3. Driver numbers are not identities. Canonical entities retain stable source
   identifiers and provider-specific identifiers in mapping tables.
4. Provider response shapes do not define public tables. Source adapters map
   into a typed canonical model before database loading.
5. Timestamps are stored as UTC `datetime2` values. Original timezone and
   offset information is retained where it is meaningful.
6. Durations and measurements use bounded numeric types and documented units.
   Unbounded string columns require a specific justification.
7. Raw source values and provenance are retained outside or alongside the
   curated public model so transformations can be audited.
8. Missing historical coverage is represented explicitly. The schema must not
   fabricate FastF1-enriched facts for seasons where they are unavailable.
9. DDL and migrations must not contain hard-coded database or server names.
10. A migration must be repeatably testable from an empty supported SQL Server
    instance and from the immediately preceding schema version.

## Compatibility

Schema v2 is allowed to be a breaking correction of the legacy model.
Compatibility views will be provided where legacy semantics can be reproduced
accurately. A compatibility view will not preserve an unsafe identity or
misrepresent a changed data grain merely to retain an old column name.

Breaking changes and removed legacy objects must be listed in a migration
guide before the first public v2 release.

## Repository coordination

The core build pins this repository at an exact commit. Every release manifest
records that commit and the schema version. Schema changes are released only
after the matching core loader and integration tests pass together.
