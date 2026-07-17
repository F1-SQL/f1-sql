"""Replaceable HTTP transport and bounded retry policy for source adapters."""

import time
from collections.abc import Callable, Mapping
from dataclasses import dataclass
from typing import Protocol
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


@dataclass(frozen=True, slots=True)
class TransportResponse:
    url: str
    status_code: int
    headers: Mapping[str, str]
    body: bytes


class Transport(Protocol):
    def request(
        self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
    ) -> TransportResponse: ...


class UrllibTransport:
    """Minimal stdlib transport; tests can replace it with an in-memory fake."""

    def request(
        self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
    ) -> TransportResponse:
        query = urlencode(params)
        request_url = f"{url}?{query}" if query else url
        request = Request(
            request_url,
            headers={"User-Agent": user_agent, "Accept": "application/json"},
        )
        try:
            with urlopen(request, timeout=timeout_seconds) as response:
                return TransportResponse(
                    url=request_url,
                    status_code=response.status,
                    headers=dict(response.headers.items()),
                    body=response.read(),
                )
        except HTTPError as exc:
            return TransportResponse(
                url=request_url,
                status_code=exc.code,
                headers=dict(exc.headers.items()),
                body=exc.read(),
            )


@dataclass(frozen=True, slots=True)
class RetryPolicy:
    max_retries: int = 3
    backoff_seconds: float = 1.0

    def __post_init__(self) -> None:
        if self.max_retries < 0:
            raise ValueError("max_retries cannot be negative")
        if self.backoff_seconds < 0:
            raise ValueError("backoff_seconds cannot be negative")


class RetryingTransport:
    """Retry only transient responses; permanent 4xx responses fail immediately."""

    def __init__(
        self,
        delegate: Transport,
        policy: RetryPolicy,
        sleep: Callable[[float], None] = time.sleep,
    ) -> None:
        self.delegate = delegate
        self.policy = policy
        self.sleep = sleep

    def request(
        self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
    ) -> TransportResponse:
        for attempt in range(self.policy.max_retries + 1):
            try:
                response = self.delegate.request(url, params, timeout_seconds, user_agent)
            except (OSError, TimeoutError):
                if attempt == self.policy.max_retries:
                    raise
                self.sleep(self.policy.backoff_seconds * (2**attempt))
                continue
            transient = response.status_code in (408, 429) or response.status_code >= 500
            if response.status_code < 400 or transient:
                if response.status_code < 400 or attempt == self.policy.max_retries:
                    return response
                self.sleep(self.policy.backoff_seconds * (2**attempt))
                continue
            return response
        raise RuntimeError("retry policy exhausted without a response")
