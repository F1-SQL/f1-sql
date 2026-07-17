# Local development

The v2 pipeline targets Python 3.11 or newer. Create an isolated environment and
install the package with development dependencies:

```sh
python -m venv .venv
. .venv/bin/activate
python -m pip install -e '.[dev]'
pytest
f1sql --version
f1sql fingerprint '{"season":2026,"round":1}'
f1sql init 2026.1
```

The offline acceptance suite also statically validates the monorepo's
`database/schema/v2` migrations for contiguous numbering, idempotency guards,
required tables, and database-neutral SQL. Live SQL Server execution is still
required before schema acceptance can be marked complete.

Phase 1 is intentionally offline. It creates deterministic manifests and a
content-addressed raw-artifact store; source adapters and SQL Server loading are
introduced in later phases.
