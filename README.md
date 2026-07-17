![](images/git-banner.png)

[![GitHub Release](https://img.shields.io/github/v/release/F1-SQL/f1-sql?style=for-the-badge&labelColor=%23333&color=%23d40000)](https://github.com/F1-SQL/F1-SQL/releases)
[![GitHub License](https://img.shields.io/github/license/F1-SQL/f1-sql?style=for-the-badge&labelColor=%23333&color=%23d40000)](LICENSE)
[![GitHub Downloads](https://img.shields.io/github/downloads/F1-SQL/f1-sql/total?style=for-the-badge&labelColor=%23333&color=%23d40000)](https://github.com/F1-SQL/f1-sql/releases)
[![GitHub Stars](https://img.shields.io/github/stars/F1-SQL/f1-sql?style=for-the-badge&labelColor=%23333&color=%23d40000)](https://github.com/F1-SQL/f1-sql/stargazers)

# F1 SQL

F1 SQL is an unofficial, community-maintained project that builds a Microsoft
SQL Server database from openly accessible Formula One data. The build tools
are open source; generated data releases are non-commercial and share-alike.

The project is maintained for education, demonstration, and community use. It
is not associated with Formula 1, the FIA, or their affiliated companies.

## Rebuild status

The project is being rebuilt around the Jolpica-F1 API and FastF1 after the
retirement of the original Ergast service. The target pipeline will:

1. detect a completed, unreleased race weekend;
2. ingest and fingerprint Jolpica-F1 and FastF1 data;
3. normalize both sources into a source-neutral model;
4. build the database from an explicit versioned schema;
5. run data-quality, integrity, backup, and restore tests; and
6. publish an immutable GitHub release only when every gate passes.

The existing PowerShell scripts and archived files remain available as legacy
reference material while the new pipeline is developed. They are not yet the
autonomous v2 release path.

## Data sources

* [Jolpica-F1](https://api.jolpi.ca/ergast/) is the primary source for seasons,
  races, circuits, drivers, constructors, official results, qualifying,
  sprints, laps, pit stops, statuses, and championship standings.
* [FastF1](https://docs.fastf1.dev/) is the primary source for sessions,
  detailed timing, tyres, stints, weather, status, and race-control data.

The ownership and reconciliation rules are documented in
[ADR 0002](docs/architecture/0002-source-ownership.md).

## Architecture and release policy

* [Rebuild architecture](docs/architecture/0001-rebuild-architecture.md)
* [Source ownership](docs/architecture/0002-source-ownership.md)
* [Component-specific licensing](docs/architecture/0003-licensing.md)
* [Monorepo layout](docs/architecture/0004-monorepo-layout.md)
* [Master rebuild checklist](docs/rebuild-master-plan.md)
* [Release policy](docs/release-policy.md)
* [Legacy data provenance audit](docs/legacy-data-audit.md)
* [Local development](docs/development.md)
* [Normalization units and tolerances](docs/normalization.md)
* [Historical coverage policy](docs/historical-coverage.md)
* [Database schema](database/schema/v2/README.md)

## Releases

Published database releases are available from the
[GitHub releases page](https://github.com/F1-SQL/F1-SQL/releases). Existing
releases use the legacy schema. The first v2 release will be clearly identified
and will include a source manifest, quality report, checksums, and attribution.

## Licensing

This repository uses component-specific licences:

* software, workflows, and configuration: [Apache-2.0](LICENSE);
* documentation: [CC BY 4.0](LICENSE-DOCS); and
* downloaded, transformed, and released data: [CC BY-NC-SA 4.0](LICENSE-DATA).

See [ATTRIBUTION.md](ATTRIBUTION.md) and [NOTICE](NOTICE) for source and
trademark notices. The data licence applies to release assets even when the
software used to build them is Apache-2.0.

## Documentation and issues

Project documentation is published at [F1SQL.com](https://www.f1sql.com/).
Please report software defects and data-quality issues through the repository's
[issue tracker](https://github.com/F1-SQL/F1-SQL/issues).

## Image credit

Header photo by
[Chethan Kanakamurthy](https://unsplash.com/@chethan_kanakamurthy), from
[Unsplash](https://unsplash.com/photos/a-black-and-white-photo-of-a-racing-car-DAhUu3oe64I).
