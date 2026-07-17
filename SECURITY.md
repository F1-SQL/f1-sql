# Security policy

Please report suspected vulnerabilities privately to the repository
maintainers rather than opening a public issue with exploit details. Do not
include API credentials, database passwords, or private raw data in reports or
fixtures.

The pipeline is designed to fail closed: source artifacts are fingerprinted,
release versions are immutable, SQL values are parameterized, and workflow
permissions default to read-only. Dependency and workflow security checks are
part of the remaining production cutover work.

