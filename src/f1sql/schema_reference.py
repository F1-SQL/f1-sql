"""Pinned database-schema repository reference used by build manifests."""

import os
import re
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class DatabaseSchemaReference:
    repository: str
    commit_sha: str
    schema_version: str

    @classmethod
    def from_env(cls, environ: dict[str, str] | None = None) -> "DatabaseSchemaReference":
        env = os.environ if environ is None else environ
        repository = env.get(
            "F1SQL_DATABASE_REPOSITORY", "https://github.com/F1-SQL/f1-sql-database"
        )
        commit_sha = env.get("F1SQL_DATABASE_REPOSITORY_SHA", "")
        schema_version = env.get("F1SQL_SCHEMA_VERSION", "2.0.0")
        if not re.fullmatch(r"[0-9a-fA-F]{40}", commit_sha):
            raise ValueError("F1SQL_DATABASE_REPOSITORY_SHA must be a 40-character commit SHA")
        if not schema_version or any(char.isspace() for char in schema_version):
            raise ValueError("F1SQL_SCHEMA_VERSION must be a non-empty token")
        return cls(repository, commit_sha.lower(), schema_version)

    def manifest_values(self) -> dict[str, str]:
        return {
            "database_repository": self.repository,
            "database_repository_sha": self.commit_sha,
            "schema_version": self.schema_version,
        }
