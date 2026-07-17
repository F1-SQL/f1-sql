# F1 SQL v2 master rebuild checklist

* Status: Active
* Started: 2026-07-17
* Last updated: 2026-07-17 (monorepo migration and unified schema/build workflow)

This is the authoritative delivery checklist for the v2 rebuild. A checked item
means its implementation and proportionate automated verification are present
in the repository. Phase acceptance boxes are checked only when every required
item in that phase is complete.

## Phase 0: decisions and project boundaries

* [x] Adopt Apache-2.0 for software and schema.
* [x] Adopt CC BY 4.0 for project documentation.
* [x] Adopt CC BY-NC-SA 4.0 for generated data releases.
* [x] Record source attribution and trademark notices.
* [x] Define source ownership and reconciliation rules.
* [x] Define the rebuild architecture and fail-closed release policy.
* [x] Define schema-v2 principles and SQL Server 2019 as the baseline.
* [x] Adopt the monorepo layout for core orchestration and the database schema.
* [x] Quarantine legacy source material pending a provenance audit.
* [x] **Acceptance:** project, data, schema, and release boundaries are explicit.

## Phase 1: application foundation

* [x] Create an installable `src`-layout Python project and `f1sql` CLI.
* [x] Add typed build-target and pipeline-stage contracts.
* [x] Add environment-driven configuration with validated defaults.
* [x] Add canonical JSON and SHA-256 fingerprint helpers.
* [x] Add the v2 run-manifest/provenance model.
* [x] Add a content-addressed raw-artifact store with integrity checks.
* [x] Add unit tests for configuration, provenance, cache, and CLI behaviour.
* [x] Add a Python CI workflow that has no live-data dependency.
* [x] Document local development and Phase 1 commands.
* [x] **Acceptance:** foundation tests and CLI smoke checks pass on a clean checkout.

## Phase 2: Jolpica ingestion and race discovery

* [x] Define a transport interface so HTTP is replaceable in tests.
* [x] Implement bounded retries, timeouts, backoff, and an identifying user agent.
* [x] Implement Jolpica pagination using response `limit`, `offset`, and `total`.
* [x] Snapshot every response before parsing and record request provenance.
* [x] Add typed source contracts for seasons, races, circuits, drivers, and constructors.
* [x] Add typed contracts for results, qualifying, sprints, laps, and pit stops.
* [x] Add typed contracts for statuses and championship standings.
* [x] Implement completed-round discovery without a maintained calendar file.
* [x] Implement the settling-period and already-released/fingerprint decisions.
* [x] Add versioned JSON fixtures for representative normal, sprint, and edge weekends.
* [x] Add pagination, retry, malformed-response, and source-contract tests.
* [x] **Acceptance:** an offline fixture run discovers and snapshots a complete round.

## Phase 3: FastF1 ingestion

* [x] Pin a supported FastF1 version range and record the resolved version in manifests.
* [x] Configure a persistent FastF1 cache inside the pipeline workspace.
* [x] Discover event sessions by season and round with exact matching.
* [x] Load session metadata and results with explicit optional-data behaviour.
* [x] Extract laps, sectors, speeds, tyres, and stints.
* [x] Extract detailed pit timing, weather, track/session status, and race control.
* [x] Record raw/cache fingerprints sufficient to replay transformations.
* [x] Handle pre-2018 coverage explicitly without manufactured rich data.
* [x] Add small serialized fixtures that do not require live FastF1 access in CI.
* [x] Add missing-session, delayed-data, sprint-format, and cancelled-session tests.
* [x] **Acceptance:** an offline fixture run produces all in-scope FastF1 source records.

## Phase 4: canonical normalization and reconciliation

* [x] Define source-neutral models for every in-scope domain.
* [x] Normalize all timestamps to UTC and durations to documented units.
* [x] Preserve Jolpica external IDs and provider-specific FastF1 identifiers.
* [x] Build deterministic driver, constructor, circuit, meeting, and session mappings.
* [x] Treat driver number as an event/session attribute.
* [x] Implement primary-source selection from ADR 0002.
* [x] Reconcile schedules, participants, winners, classified results, and lap counts.
* [x] Define documented precision tolerances for cross-source timing comparisons.
* [x] Emit structured discrepancies with severity and source evidence.
* [x] Serialize normalized records deterministically for replay.
* [x] Add golden-file and ambiguity/failure tests.
* [x] **Acceptance:** identical snapshots produce byte-equivalent normalized output.

## Phase 5: schema v2 and deterministic database build

* [x] Inventory every legacy table and mark it retain, redesign, replace, or retire.
* [x] Define schema versioning and forward-only migration conventions.
* [x] Create schema-first DDL with bounded types, UTC semantics, and descriptions.
* [x] Add primary, foreign, unique, check, and required-value constraints in DDL.
* [x] Add provenance, external-identifier, build, release, and schema-history tables.
* [x] Remove hard-coded database names and table inference.
* [x] Implement ordered, transactional, idempotent loaders.
* [x] Pin the monorepo commit and `database/schema/v2` path in the build manifest.
* [x] Add compatibility views only where legacy meaning can be preserved accurately.
* [x] Add schema creation, migration, idempotency, and rollback tests.
* [x] **Acceptance:** a database can be rebuilt from empty SQL Server using snapshots only.

## Phase 6: data quality and database verification

* [x] Define machine-readable quality rules and severity levels.
* [x] Validate keys, uniqueness, required values, orphans, and row-count invariants.
* [x] Validate event, session, participant, result, lap, and stint coverage.
* [x] Fail on identity ambiguity or contradictory winner/round mappings.
* [x] Report allowed historical and provider coverage gaps separately from defects.
* [x] Run source-to-normalized and normalized-to-database reconciliation.
* [x] Run representative smoke queries and query-result snapshots.
* [x] Run `DBCC CHECKDB` and backup verification.
* [x] Restore a fresh backup and repeat integrity and smoke checks.
* [x] Emit `quality-report.json` with rule outcomes, evidence, and row counts.
* [x] Add deliberate-corruption and negative-path tests proving fail-closed behaviour.
* [x] **Acceptance:** bad fixtures cannot reach packaging and a good fixture passes every gate.

## Phase 7: packaging and reproducible releases

* [x] Produce the compressed SQL Server 2019-compatible backup.
* [x] Finalize `manifest.json` schema and validate it before packaging.
* [x] Generate `checksums.sha256` over every release asset.
* [x] Bundle data licence, notice, attribution, quality report, and release notes.
* [x] Implement `season.round.revision` version calculation and correction handling.
* [x] Make packaging deterministic except for explicitly documented backup metadata.
* [x] Implement dry-run and staging modes that cannot publish.
* [x] Prevent asset replacement for an existing release version.
* [x] Add archive-content, checksum, manifest, and duplicate-release tests.
* [x] **Acceptance:** fixture inputs produce a complete, locally verifiable release bundle.

## Phase 8: autonomous GitHub Actions delivery

* [x] Add scheduled readiness detection and manual workflow dispatch.
* [x] Separate the lightweight detector from the production SQL Server build job.
* [x] Add workflow concurrency so only one release build can run at once.
* [x] Use least-privilege permissions and protect publish environments.
* [x] Pin third-party actions by full commit SHA.
* [x] Persist raw snapshots and FastF1 cache data across runs where permitted.
* [x] Build and test against SQL Server 2019; restore-forward test on SQL Server 2022.
* [x] Upload diagnostic artifacts on failure without publishing release assets.
* [ ] Create the tag and GitHub release only after every validation gate passes.
* [x] Add workflow tests or static validation for triggers, permissions, and conditions.
* [x] Document secrets, environment protection, reruns, and recovery.
* [ ] **Acceptance:** a manual dry run exercises the complete workflow without publishing.

## Phase 9: historical backfill and migration

* [x] Define supported historical coverage per table and source.
* [ ] Audit retained legacy data provenance and decide item-by-item eligibility.
* [ ] Backfill Jolpica historical championship data in bounded, resumable batches.
* [ ] Backfill FastF1 rich data for supported seasons.
* [x] Record known gaps and corrections without inventing values.
* [ ] Compare v2 results and standings with representative legacy releases.
* [ ] Benchmark build time, storage, API use, and release-asset size.
* [ ] Produce the first release candidate and complete manual data review.
* [x] Document legacy-to-v2 table and column mappings.
* [ ] **Acceptance:** the release candidate meets declared historical coverage and quality gates.

## Phase 10: cutover and ongoing operations

* [ ] Publish user installation, restore, upgrade, and troubleshooting documentation.
* [x] Publish contributor setup, architecture, testing, and source-change guidance.
* [x] Add security policy, dependency updates, and vulnerability scanning.
* [x] Define supported Python, FastF1, and SQL Server version policies.
* [x] Define source-schema change detection and fixture refresh procedures.
* [ ] Define release failure alerts and maintainer incident runbooks.
* [ ] Mark legacy scripts read-only and remove them from active workflows.
* [ ] Publish the v2 stable release and migration announcement.
* [ ] Verify the first autonomous post-race release and document the review.
* [ ] **Acceptance:** maintainers can operate, recover, and update the project from documentation.

## Deferred scope

These require a separate source and design decision and do not block v2:

* high-frequency car telemetry;
* continuous interval and running-position samples; and
* team-radio audio or metadata.
