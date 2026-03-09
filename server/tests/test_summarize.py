import pytest
from unittest.mock import patch

pytestmark = pytest.mark.asyncio


async def test_summarize_success(client):
    mock_result = {
        "summary": "This is a summary",
        "key_points": ["Point 1", "Point 2"],
        "action_points": ["Action 1"],
    }

    with patch("routers.summarize.gemini_service.summarize", return_value=mock_result):
        response = await client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "transcript": "Some long transcript text here",
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["video_id"] == "test123"
    assert data["summary"] == "This is a summary"
    assert data["key_points"] == ["Point 1", "Point 2"]
    assert data["action_points"] == ["Action 1"]


async def test_summarize_empty_transcript(client):
    response = await client.post(
        "/api/v1/summarize",
        json={"video_id": "test123", "transcript": ""},
    )
    assert response.status_code == 400


async def test_summarize_gemini_error(client):
    with patch(
        "routers.summarize.gemini_service.summarize",
        side_effect=Exception("Gemini API error"),
    ):
        response = await client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "transcript": "Some transcript",
            },
        )
    assert response.status_code == 500


async def test_summarize_missing_fields(client):
    response = await client.post("/api/v1/summarize", json={"video_id": "test123"})
    assert response.status_code == 422
