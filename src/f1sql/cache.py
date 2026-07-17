"""Content-addressed storage for immutable raw source responses."""

from dataclasses import dataclass
from pathlib import Path

from .fingerprint import sha256_bytes


@dataclass(frozen=True, slots=True)
class StoredArtifact:
    digest: str
    path: Path
    size_bytes: int


class ArtifactStore:
    """Store bytes under their SHA-256 digest and verify before every read."""

    def __init__(self, root: Path) -> None:
        self.root = root

    def put(self, content: bytes, suffix: str = ".json") -> StoredArtifact:
        digest = sha256_bytes(content)
        safe_suffix = suffix if suffix.startswith(".") and "/" not in suffix else ".bin"
        path = self.root / digest[:2] / f"{digest}{safe_suffix}"
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            if sha256_bytes(path.read_bytes()) != digest:
                raise OSError(f"cache integrity failure: {path}")
        else:
            path.write_bytes(content)
        return StoredArtifact(digest=digest, path=path, size_bytes=len(content))

    def read(self, digest: str, suffix: str = ".json") -> bytes:
        path = self.root / digest[:2] / f"{digest}{suffix}"
        content = path.read_bytes()
        if sha256_bytes(content) != digest:
            raise OSError(f"cache integrity failure: {path}")
        return content
