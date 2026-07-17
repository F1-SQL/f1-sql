from collections.abc import Mapping

from f1sql.transport import RetryingTransport, RetryPolicy, TransportResponse


class SequenceTransport:
    def __init__(self, responses: list[TransportResponse]) -> None:
        self.responses = responses

    def request(
        self, url: str, params: Mapping[str, str], timeout_seconds: int, user_agent: str
    ) -> TransportResponse:
        return self.responses.pop(0)


def test_retry_policy_retries_transient_statuses() -> None:
    sleeps: list[float] = []
    delegate = SequenceTransport(
        [
            TransportResponse("https://example.test", 503, {}, b"busy"),
            TransportResponse("https://example.test", 200, {}, b"ok"),
        ]
    )
    response = RetryingTransport(delegate, RetryPolicy(max_retries=2), sleeps.append).request(
        "https://example.test", {}, 1, "test"
    )
    assert response.status_code == 200
    assert sleeps == [1.0]


def test_retry_policy_does_not_retry_permanent_client_errors() -> None:
    sleeps: list[float] = []
    delegate = SequenceTransport([TransportResponse("https://example.test", 404, {}, b"no")])
    response = RetryingTransport(delegate, RetryPolicy(max_retries=2), sleeps.append).request(
        "https://example.test", {}, 1, "test"
    )
    assert response.status_code == 404
    assert sleeps == []
