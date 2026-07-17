# Schema v2

Schema v2 is applied forward-only, from an empty SQL Server database, using
ordered numbered scripts. Scripts must be deterministic, idempotent where
possible, and must not contain a database name. The pipeline pins this
repository at an exact commit in its build manifest.

`0001_metadata.sql` creates the metadata tables needed before domain data can
be loaded. `0002_core_domain.sql` defines the first source-neutral dimensions
and event/session facts with bounded types and active constraints.
`0003_compatibility_views.sql` adds only the unambiguous two-column
`legacy_teams` projection; legacy seasons, circuits, and drivers retain fields
that v2 does not model and therefore do not receive compatibility views.

The Phase 5 SQL Server integration assertions live in
`../tests/phase5_integration.sql`. Run them with `sqlcmd -b` against a
disposable database after applying the numbered scripts; they verify table
count, `MERGE` idempotency, rollback, and check-constraint behavior.
After applying the rendered fixture load plan, run
`../tests/phase5_fixture_smoke.sql` for normalized-to-database row-count and
join smoke assertions.

Compatibility views are opt-in and may only be added when their legacy meaning
is unambiguous. No legacy corrective script is part of the v2 migration path.
