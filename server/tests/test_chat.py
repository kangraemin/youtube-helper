import pytest
from unittest.mock import patch

pytestmark = pytest.mark.asyncio


async def test_chat_success(client):
    with patch("routers.chat.gemini_service.chat", return_value="This is an AI reply"):
        response = await client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript": "Some transcript",
                "message": "What is this video about?",
                "history": [],
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["video_id"] == "test123"
    assert data["reply"] == "This is an AI reply"


async def test_chat_with_history(client):
    history = [
        {"role": "user", "content": "Hello"},
        {"role": "assistant", "content": "Hi there!"},
    ]

    with patch("routers.chat.gemini_service.chat", return_value="Follow-up reply"):
        response = await client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript": "Some transcript",
                "message": "Tell me more",
                "history": history,
            },
        )

    assert response.status_code == 200
    data = response.json()
    assert data["reply"] == "Follow-up reply"


async def test_chat_empty_message(client):
    response = await client.post(
        "/api/v1/chat",
        json={
            "video_id": "test123",
            "transcript": "Some transcript",
            "message": "",
            "history": [],
        },
    )
    assert response.status_code == 400


async def test_chat_gemini_error(client):
    with patch(
        "routers.chat.gemini_service.chat",
        side_effect=Exception("Gemini API error"),
    ):
        response = await client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript": "Some transcript",
                "message": "Question",
                "history": [],
            },
        )
    assert response.status_code == 500


async def test_chat_missing_fields(client):
    response = await client.post("/api/v1/chat", json={"video_id": "test123"})
    assert response.status_code == 422
