# Compatibility policy

The v2 baseline is Python 3.11+, FastF1 in the supported range declared in
`pyproject.toml`, and SQL Server 2019. SQL Server 2022 is a restore-forward
compatibility target. Jolpica is consumed through its versioned Ergast
compatibility API and all raw responses are retained as snapshots.

Breaking schema changes require a new schema major version and a forward-only
migration. Provider contract changes require a refreshed fixture, a source
version update in the manifest, and a quality-rule review before release.

