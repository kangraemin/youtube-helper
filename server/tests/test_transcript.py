import pytest
from unittest.mock import patch, MagicMock

pytestmark = pytest.mark.asyncio


async def test_transcript_success(client):
    mock_transcript = [
        {"text": "Hello world", "start": 0.0, "duration": 5.0},
        {"text": "This is a test", "start": 5.0, "duration": 760.0},
    ]
    mock_oembed = {"title": "Test Video"}

    with patch("routers.transcript.youtube_service.get_transcript", return_value=mock_transcript), \
         patch("routers.transcript.youtube_service.get_video_title", return_value="Test Video"):
        response = await client.post(
            "/api/v1/transcript",
            json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"},
        )

    assert response.status_code == 200
    data = response.json()
    assert data["video_id"] == "dQw4w9WgXcQ"
    assert data["title"] == "Test Video"
    assert data["thumbnail_url"] == "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
    assert data["transcript"] == "Hello world This is a test"
    assert data["duration"] is not None


async def test_transcript_invalid_url(client):
    response = await client.post(
        "/api/v1/transcript",
        json={"url": "not-a-valid-url"},
    )
    assert response.status_code == 400


async def test_transcript_not_found(client):
    with patch(
        "routers.transcript.youtube_service.get_transcript",
        side_effect=Exception("No transcript found"),
    ), patch(
        "routers.transcript.youtube_service.get_video_title",
        return_value="Some Video",
    ):
        response = await client.post(
            "/api/v1/transcript",
            json={"url": "https://www.youtube.com/watch?v=nonexistent"},
        )
    assert response.status_code == 404


async def test_transcript_missing_url(client):
    response = await client.post("/api/v1/transcript", json={})
    assert response.status_code == 422
