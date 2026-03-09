import pytest
from unittest.mock import patch, MagicMock, AsyncMock
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.fixture
def client():
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")


def _mock_fetch_result():
    """Create mock transcript result matching youtube-transcript-api v1.x."""
    snippet1 = MagicMock()
    snippet1.text = "Hello world"
    snippet1.start = 0.0
    snippet1.duration = 1.5

    snippet2 = MagicMock()
    snippet2.text = "This is a test"
    snippet2.start = 1.5
    snippet2.duration = 2.0

    return [snippet1, snippet2]


def _mock_oembed_response():
    resp = MagicMock()
    resp.status_code = 200
    resp.json.return_value = {"title": "Test Video Title"}
    return resp


@pytest.mark.anyio
async def test_transcript_success(client):
    mock_snippets = _mock_fetch_result()

    with patch("services.youtube.YouTubeTranscriptApi") as MockYTT, \
         patch("services.youtube.requests.get") as mock_get:
        instance = MockYTT.return_value
        instance.fetch.return_value = mock_snippets
        mock_get.return_value = _mock_oembed_response()

        resp = await client.post("/api/v1/transcript", json={
            "url": "https://www.youtube.com/watch?v=abc123"
        })

    assert resp.status_code == 200
    data = resp.json()
    assert data["video_id"] == "abc123"
    assert data["title"] == "Test Video Title"
    assert data["thumbnail_url"] == "https://img.youtube.com/vi/abc123/hqdefault.jpg"
    assert len(data["transcript"]) == 2
    assert data["transcript"][0]["text"] == "Hello world"
    assert data["transcript"][0]["start"] == 0.0
    assert data["transcript"][0]["duration"] == 1.5
    assert data["full_text"] == "Hello world This is a test"
    assert data["language"] == "ko"


@pytest.mark.anyio
async def test_transcript_youtu_be_url(client):
    mock_snippets = _mock_fetch_result()

    with patch("services.youtube.YouTubeTranscriptApi") as MockYTT, \
         patch("services.youtube.requests.get") as mock_get:
        instance = MockYTT.return_value
        instance.fetch.return_value = mock_snippets
        mock_get.return_value = _mock_oembed_response()

        resp = await client.post("/api/v1/transcript", json={
            "url": "https://youtu.be/xyz789"
        })

    assert resp.status_code == 200
    assert resp.json()["video_id"] == "xyz789"


@pytest.mark.anyio
async def test_transcript_embed_url(client):
    mock_snippets = _mock_fetch_result()

    with patch("services.youtube.YouTubeTranscriptApi") as MockYTT, \
         patch("services.youtube.requests.get") as mock_get:
        instance = MockYTT.return_value
        instance.fetch.return_value = mock_snippets
        mock_get.return_value = _mock_oembed_response()

        resp = await client.post("/api/v1/transcript", json={
            "url": "https://www.youtube.com/embed/embed123"
        })

    assert resp.status_code == 200
    assert resp.json()["video_id"] == "embed123"


@pytest.mark.anyio
async def test_transcript_shorts_url(client):
    mock_snippets = _mock_fetch_result()

    with patch("services.youtube.YouTubeTranscriptApi") as MockYTT, \
         patch("services.youtube.requests.get") as mock_get:
        instance = MockYTT.return_value
        instance.fetch.return_value = mock_snippets
        mock_get.return_value = _mock_oembed_response()

        resp = await client.post("/api/v1/transcript", json={
            "url": "https://www.youtube.com/shorts/short456"
        })

    assert resp.status_code == 200
    assert resp.json()["video_id"] == "short456"


@pytest.mark.anyio
async def test_transcript_invalid_url(client):
    resp = await client.post("/api/v1/transcript", json={
        "url": "https://www.example.com/not-youtube"
    })
    assert resp.status_code == 400


@pytest.mark.anyio
async def test_transcript_no_transcript(client):
    with patch("services.youtube.YouTubeTranscriptApi") as MockYTT:
        instance = MockYTT.return_value
        instance.fetch.side_effect = Exception("No transcript found")

        resp = await client.post("/api/v1/transcript", json={
            "url": "https://www.youtube.com/watch?v=notranscript"
        })

    assert resp.status_code == 404


@pytest.mark.anyio
async def test_transcript_missing_url_field(client):
    resp = await client.post("/api/v1/transcript", json={})
    assert resp.status_code == 422
