"""Validated SQL Server backup and verification command generation."""

import re
from dataclasses import dataclass

_IDENTIFIER = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


@dataclass(frozen=True, slots=True)
class BackupRequest:
    database: str
    server_path: str
    compression: bool = True
    checksum: bool = True


def backup_sql(request: BackupRequest) -> str:
    """Return a deterministic SQL Server 2019 backup command."""

    database = _identifier(request.database)
    path = _path_literal(request.server_path)
    options = ["INIT"]
    if request.compression:
        options.append("COMPRESSION")
    if request.checksum:
        options.append("CHECKSUM")
    options.append("STATS = 10")
    return (
        f"BACKUP DATABASE [{database}] TO DISK = N'{path}' "
        f"WITH {', '.join(options)};"
    )


def verify_backup_sql(server_path: str) -> str:
    """Return a checksum-enforcing RESTORE VERIFYONLY command."""

    return f"RESTORE VERIFYONLY FROM DISK = N'{_path_literal(server_path)}' WITH CHECKSUM;"


def _identifier(value: str) -> str:
    if not _IDENTIFIER.fullmatch(value):
        raise ValueError(f"unsafe database identifier: {value!r}")
    return value


def _path_literal(value: str) -> str:
    if not value or "\x00" in value or "'" in value:
        raise ValueError("backup path contains unsafe characters")
    return value
