# SQL Server loading contract

`f1sql.load_plan.build_load_plan` produces rows in foreign-key-safe order. The
`f1sql.sqlserver.TransactionalLoader` is the only execution boundary: it runs
every operation in one transaction, commits only after all operations succeed,
and rolls back on the first error.

`default_statement_factories` maps every load-plan table explicitly to the v2
`f1sql` column names. The factories use `merge_statement` and return generated
SQL plus parameter tuples. `merge_statement` validates and quotes identifiers,
uses DB-API `?` parameters for values, and updates existing rows or inserts new
rows. This makes rerunning a snapshot idempotent without embedding database
names or relying on inferred table relationships.

Live SQL Server execution remains an integration-gated task. Unit tests use a
small DB-API protocol fake; CI must add SQL Server 2019 and 2022 containers
before the schema-creation, migration, backup, and restore checklist items can
be marked complete.

`f1sql.backup` generates validated `BACKUP DATABASE` and `RESTORE VERIFYONLY`
commands. Once the backup has been created and verified by the SQL Server
runner, pass its path as `database_backup` to the pipeline so it is included as
the immutable `database.bak` release asset.
