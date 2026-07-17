import pytest

from f1sql.backup import BackupRequest, backup_sql, verify_backup_sql


def test_backup_commands_are_compressed_and_checksummed() -> None:
    request = BackupRequest("F1SqlPhase5", "/var/opt/mssql/backup/F1SqlPhase5.bak")
    command = backup_sql(request)
    assert "BACKUP DATABASE [F1SqlPhase5]" in command
    assert "COMPRESSION" in command
    assert "CHECKSUM" in command
    assert verify_backup_sql(request.server_path).endswith("WITH CHECKSUM;")


def test_backup_commands_reject_unsafe_values() -> None:
    with pytest.raises(ValueError):
        backup_sql(BackupRequest("F1SqlPhase5;DROP", "/tmp/a.bak"))
    with pytest.raises(ValueError):
        verify_backup_sql("/tmp/a.bak' ; DROP DATABASE F1SqlPhase5")
