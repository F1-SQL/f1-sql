# ADR 0004: Monorepo layout

* Status: Accepted
* Date: 2026-07-17

## Context

The ingestion code, SQL mappings, migrations, Docker verification, and release
workflow change as one unit. Keeping the schema in a second repository required
cross-repository checkouts, branch variables, and two commit references in every
release build. A missing checkout caused otherwise valid tests to fail.

## Decision

`f1-sql` is the canonical monorepo. The former database repository is preserved
under `database/`, including its history, legacy reference material, v2 schema,
and SQL tests. The production schema path is `database/schema/v2`.

Release manifests keep the historical `database_repository_sha` field for
compatibility, but it now identifies the monorepo commit. They also record
`database_repository` and `database_schema_path` so consumers can locate the
schema unambiguously.

The former `f1-sql-database` repository may remain as an archived compatibility
mirror, but it is not an independent release input.

## Consequences

* Schema and loader changes are reviewed and tested in one pull request.
* Workflows no longer need a second checkout or database-ref variable.
* The database subdirectory remains easy to export for schema-only consumers.
* A release commit is the single reproducibility anchor for code and schema.
* Existing database-repository links should redirect to the monorepo schema
  path or be documented as historical references.
