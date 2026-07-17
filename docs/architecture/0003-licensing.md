# ADR 0003: Component-specific licensing

* Status: Accepted
* Date: 2026-07-17

## Context

The repositories previously used a blanket CC BY 4.0 licence. The rebuild
contains open-source software, documentation, and data derived from sources
whose terms differ. Jolpica-F1 currently distributes API data for
non-commercial use under CC BY-NC-SA 4.0.

Applying one licence to every component would either incorrectly restrict the
software or incorrectly relicense the data.

## Decision

* Software, SQL source, workflows, and configuration are Apache-2.0.
* Human-readable documentation is CC BY 4.0.
* F1 SQL's contributions to normalized, exported, and released v2 data are
  CC BY-NC-SA 4.0 unless a more specific compatible upstream notice applies.
* Raw third-party source material retains its original terms and is not
  relicensed merely by being cached or stored by the project.
* Release artifacts include the data licence, attribution, source manifest,
  and an indication of transformations.
* Project descriptions use the precise phrase "open-source build tools with
  non-commercial, share-alike data releases" rather than claiming that the
  complete data distribution is OSI open source.

## Licence boundaries

`LICENSE` covers software and SQL source. `LICENSE-DOCS` covers documentation.
`LICENSE-DATA` covers data paths and generated release artifacts. `NOTICE` and
`ATTRIBUTION.md` record project and upstream notices.

Legacy files that predate this decision are retained for historical reference
and excluded from v2 release inputs until their provenance has been audited.

The build manifest must identify the version or retrieval date of applicable
upstream terms. Upstream terms will be reviewed periodically and before any
material change in distribution or project purpose.

## Consequences

* Downstream users may use the build software commercially under Apache-2.0.
* Downstream users may not use CC BY-NC-SA data releases commercially without
  obtaining any additional permissions required by the data providers.
* FastF1's MIT software licence is acknowledged separately and is not treated
  as a licence to upstream timing data.
* The rebuild must not copy legacy datasets into a v2 release solely because
  they already exist in the repository.
