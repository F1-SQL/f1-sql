# ADR 0001: Rebuild architecture

* Status: Accepted
* Date: 2026-07-17

## Context

The legacy build downloads CSV files, allows the import tool to infer table
schemas, and then applies ordered corrective SQL scripts. It depends on local
Windows SQL Server instances and a manually maintained race calendar. These
properties make unattended, repeatable releases unsafe.

The replacement must ingest Jolpica-F1 and FastF1 data, build a deterministic
SQL Server database, validate the finished database, and publish a release
after each completed race weekend.

## Decision

1. Python will be the primary orchestration language because FastF1 exposes a
   native Python API. PowerShell may remain as an optional local wrapper.
2. Jolpica-F1 and FastF1 will be implemented as independent source adapters.
   The canonical model will not expose either provider's response shape.
3. The pipeline will have explicit `discover`, `ingest`, `normalize`, `build`,
   `validate`, `package`, and `release` stages.
4. Source responses and normalized records will be fingerprinted. Repeating a
   build with the same inputs and code must produce equivalent database
   content and a no-op release decision.
5. SQL tables will be created from versioned DDL before data is loaded. Schema
   inference and post-import corrective table creation are prohibited.
6. The core pipeline and SQL schema live in one monorepo. Release manifests
   record the monorepo commit, schema path/version, and all source/library
   versions.
7. GitHub Actions will provide scheduled detection and manual dispatch. A
   concurrency lock will prevent two release builds from running at once.
8. A release is fail-closed: no tag or public release is created unless source
   readiness, data quality, integrity, backup, and restore tests all pass.

## Pipeline layers

* **Raw:** immutable source responses and FastF1 cache material.
* **Normalized:** typed, source-neutral records suitable for deterministic
  loading and replay.
* **Database:** schema-first SQL Server database with active constraints.
* **Release:** compressed backup, manifest, checksums, attribution, and quality
  report.

## Consequences

* The legacy scripts remain historical reference material during the rebuild;
  they will not be extended into the new release path.
* Initial historical ingestion is separate from the small post-race update.
* Durable source snapshots are required for reproducible releases; transient
  GitHub Actions caches alone are insufficient.
* Schema and ingestion changes are reviewed atomically. The monorepo commit and
  schema path keep each release reproducible without a second checkout.
