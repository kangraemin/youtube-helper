import pytest
from unittest.mock import patch, AsyncMock
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.fixture
def client():
    transport = ASGITransport(app=app)
    return AsyncClient(transport=transport, base_url="http://test")


@pytest.mark.anyio
async def test_chat_success(client):
    with patch("api.v1.chat.chat_with_context", new_callable=AsyncMock) as mock_chat:
        mock_chat.return_value = "This video talks about AI and machine learning."

        resp = await client.post("/api/v1/chat", json={
            "video_id": "abc123",
            "full_text": "Transcript about AI and ML concepts.",
            "messages": [
                {"role": "user", "content": "What is this video about?"}
            ]
        })

    assert resp.status_code == 200
    data = resp.json()
    assert data["video_id"] == "abc123"
    assert data["reply"] == "This video talks about AI and machine learning."


@pytest.mark.anyio
async def test_chat_multiple_messages(client):
    with patch("api.v1.chat.chat_with_context", new_callable=AsyncMock) as mock_chat:
        mock_chat.return_value = "The key point is about neural networks."

        resp = await client.post("/api/v1/chat", json={
            "video_id": "abc123",
            "full_text": "Transcript text",
            "messages": [
                {"role": "user", "content": "What is this about?"},
                {"role": "assistant", "content": "It's about AI."},
                {"role": "user", "content": "What's the key point?"}
            ]
        })

    assert resp.status_code == 200
    assert resp.json()["reply"] == "The key point is about neural networks."


@pytest.mark.anyio
async def test_chat_missing_fields(client):
    resp = await client.post("/api/v1/chat", json={
        "video_id": "abc123"
    })
    assert resp.status_code == 422


@pytest.mark.anyio
async def test_chat_gemini_failure(client):
    with patch("api.v1.chat.chat_with_context", new_callable=AsyncMock) as mock_chat:
        mock_chat.side_effect = Exception("Gemini error")

        resp = await client.post("/api/v1/chat", json={
            "video_id": "abc123",
            "full_text": "Some text",
            "messages": [{"role": "user", "content": "Hello"}]
        })

    assert resp.status_code == 500
