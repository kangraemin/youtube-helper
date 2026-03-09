import pytest
from unittest.mock import patch, MagicMock, AsyncMock
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.fixture
def client():
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")


def _mock_gemini_summary():
    return {
        "summary": "This is a summary",
        "key_points": ["Point 1", "Point 2", "Point 3"],
        "full_summary": "This is the full detailed summary of the video."
    }


@pytest.mark.anyio
async def test_summarize_success(client):
    with patch("api.v1.summarize.generate_summary", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = _mock_gemini_summary()

        resp = await client.post("/api/v1/summarize", json={
            "video_id": "abc123",
            "title": "Test Video",
            "full_text": "Some transcript text here for summarization.",
            "language": "ko"
        })

    assert resp.status_code == 200
    data = resp.json()
    assert data["video_id"] == "abc123"
    assert data["summary"] == "This is a summary"
    assert len(data["key_points"]) == 3
    assert data["full_summary"] == "This is the full detailed summary of the video."


@pytest.mark.anyio
async def test_summarize_missing_fields(client):
    resp = await client.post("/api/v1/summarize", json={
        "video_id": "abc123"
    })
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_summarize_gemini_failure(client):
    with patch("api.v1.summarize.generate_summary", new_callable=AsyncMock) as mock_gen:
        mock_gen.side_effect = Exception("Gemini API error")

        resp = await client.post("/api/v1/summarize", json={
            "video_id": "abc123",
            "title": "Test Video",
            "full_text": "Some text",
            "language": "ko"
        })

    assert resp.status_code == 500
