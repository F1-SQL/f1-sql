"""Validated environment configuration for local and CI pipeline runs."""

import os
from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path

DEFAULT_JOLPICA_BASE_URL = "https://api.jolpi.ca/ergast/f1"
DEFAULT_USER_AGENT = "f1-sql/2.x (+https://github.com/F1-SQL/f1-sql)"


def _positive_int(name: str, value: str) -> int:
    try:
        parsed = int(value)
    except ValueError as exc:
        raise ValueError(f"{name} must be an integer") from exc
    if parsed <= 0:
        raise ValueError(f"{name} must be positive")
    return parsed


@dataclass(frozen=True, slots=True)
class Settings:
    """Runtime settings; no network or filesystem side effects occur on load."""

    workspace: Path
    raw_dir: Path
    output_dir: Path
    fastf1_cache_dir: Path
    jolpica_base_url: str = DEFAULT_JOLPICA_BASE_URL
    request_timeout_seconds: int = 30
    max_retries: int = 3
    settling_hours: int = 24
    user_agent: str = DEFAULT_USER_AGENT

    @classmethod
    def from_env(
        cls, environ: Mapping[str, str] | None = None, cwd: Path | None = None
    ) -> "Settings":
        env = os.environ if environ is None else environ
        root = Path(env.get("F1SQL_WORKSPACE", str(cwd or Path.cwd()))).expanduser()
        state = root / ".f1sql"
        timeout = _positive_int(
            "F1SQL_REQUEST_TIMEOUT_SECONDS", env.get("F1SQL_REQUEST_TIMEOUT_SECONDS", "30")
        )
        retries = _positive_int("F1SQL_MAX_RETRIES", env.get("F1SQL_MAX_RETRIES", "3"))
        settling = _positive_int("F1SQL_SETTLING_HOURS", env.get("F1SQL_SETTLING_HOURS", "24"))
        base_url = env.get("F1SQL_JOLPICA_BASE_URL", DEFAULT_JOLPICA_BASE_URL).rstrip("/")
        if not base_url.startswith(("https://", "http://")):
            raise ValueError("F1SQL_JOLPICA_BASE_URL must be an HTTP(S) URL")
        return cls(
            workspace=root,
            raw_dir=Path(env.get("F1SQL_RAW_DIR", str(state / "raw"))).expanduser(),
            output_dir=Path(env.get("F1SQL_OUTPUT_DIR", str(state / "output"))).expanduser(),
            fastf1_cache_dir=Path(
                env.get("F1SQL_FASTF1_CACHE_DIR", str(state / "fastf1-cache"))
            ).expanduser(),
            jolpica_base_url=base_url,
            request_timeout_seconds=timeout,
            max_retries=retries,
            settling_hours=settling,
            user_agent=env.get("F1SQL_USER_AGENT", DEFAULT_USER_AGENT),
        )

    def create_directories(self) -> None:
        """Create only the explicitly configured pipeline directories."""

        self.raw_dir.mkdir(parents=True, exist_ok=True)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.fastf1_cache_dir.mkdir(parents=True, exist_ok=True)
