![](images/git-banner.png)

[![GitHub Release](https://img.shields.io/github/v/release/F1-SQL/f1-sql?style=for-the-badge&labelColor=%23333&color=%23d40000)](https://github.com/F1-SQL/f1-sql/releases)
[![GitHub License](https://img.shields.io/github/license/F1-SQL/f1-sql?style=for-the-badge&labelColor=%23333&color=%23d40000)](../LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/F1-SQL/f1-sql?style=for-the-badge&labelColor=%23333&color=%23d40000)](https://github.com/F1-SQL/f1-sql/stargazers)

# F1 SQL Database

This repository defines the Microsoft SQL Server schema used by F1 SQL. It is
being redesigned for a deterministic build from Jolpica-F1 and FastF1 data.

The matching ingestion, validation, packaging, and release orchestration lives
in the parent monorepo.

## Rebuild status

The exported `Tables/` definitions and ordered corrective scripts describe the
legacy database and remain available as migration reference material. Schema v2
will replace this process with:

* explicit, versioned DDL applied before loading data;
* stable entity and source-identifier mappings;
* active primary keys, foreign keys, uniqueness constraints, and indexes;
* UTC timestamps and documented measurement units;
* tested migrations without hard-coded database names; and
* compatibility views where legacy semantics can be represented accurately.

The accepted design rules are recorded in
[Schema v2 principles](docs/schema-v2-principles.md).

The initial v2 metadata DDL is in
[`schema/v2/0001_metadata.sql`](schema/v2/0001_metadata.sql), and the legacy
table disposition is documented in
[the inventory](docs/legacy-table-inventory.md).

## Monorepo contract

The core build consumes `database/schema/v2` from the same monorepo commit.
Every database release records that commit, path, and schema version in its
build manifest. Schema changes are released only with a matching, tested core
loader.

## Licensing

SQL source, migrations, tests, and configuration are licensed under
[Apache-2.0](LICENSE). Human-readable documentation is licensed under
[CC BY 4.0](LICENSE-DOCS).

Generated databases and exported Formula One data are not relicensed by this
schema directory. They are distributed by the monorepo under the data
licence included with each release, currently CC BY-NC-SA 4.0.

See [NOTICE](NOTICE) for additional information.

## Documentation

Project documentation is published at [F1SQL.com](https://www.f1sql.com/).
