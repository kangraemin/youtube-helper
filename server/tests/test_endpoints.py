from unittest.mock import patch, AsyncMock

import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


class TestTranscriptEndpoint:
    @patch("api.v1.endpoints.fetch_transcript_with_metadata", new_callable=AsyncMock)
    def test_transcript_success(self, mock_fetch):
        mock_fetch.return_value = {
            "video_id": "dQw4w9WgXcQ",
            "title": "Test Video",
            "thumbnail_url": "https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
            "transcript": "Hello world",
            "language": "en",
        }

        resp = client.post("/api/v1/transcript", json={"url": "https://youtube.com/watch?v=dQw4w9WgXcQ"})
        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "dQw4w9WgXcQ"
        assert data["title"] == "Test Video"
        assert data["transcript"] == "Hello world"

    @patch("api.v1.endpoints.fetch_transcript_with_metadata", new_callable=AsyncMock)
    def test_transcript_invalid_url(self, mock_fetch):
        mock_fetch.side_effect = ValueError("Cannot extract video ID")

        resp = client.post("/api/v1/transcript", json={"url": "invalid"})
        assert resp.status_code == 400

    @patch("api.v1.endpoints.fetch_transcript_with_metadata", new_callable=AsyncMock)
    def test_transcript_server_error(self, mock_fetch):
        mock_fetch.side_effect = RuntimeError("Network error")

        resp = client.post("/api/v1/transcript", json={"url": "https://youtube.com/watch?v=abc"})
        assert resp.status_code == 500


class TestSummarizeEndpoint:
    @patch("api.v1.endpoints.summarize_transcript", new_callable=AsyncMock)
    def test_summarize_success(self, mock_summarize):
        mock_summarize.return_value = {
            "video_id": "abc",
            "summary": "A great summary",
            "key_points": ["point1"],
            "sections": [{"title": "Intro", "content": "Introduction content"}],
        }

        resp = client.post("/api/v1/summarize", json={
            "video_id": "abc",
            "transcript": "Some transcript text",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["summary"] == "A great summary"
        assert len(data["key_points"]) == 1

    @patch("api.v1.endpoints.summarize_transcript", new_callable=AsyncMock)
    def test_summarize_error(self, mock_summarize):
        mock_summarize.side_effect = RuntimeError("Gemini error")

        resp = client.post("/api/v1/summarize", json={
            "video_id": "abc",
            "transcript": "text",
        })
        assert resp.status_code == 500


class TestChatEndpoint:
    @patch("api.v1.endpoints.chat_with_transcript", new_callable=AsyncMock)
    def test_chat_success(self, mock_chat):
        mock_chat.return_value = "This is the answer"

        resp = client.post("/api/v1/chat", json={
            "video_id": "abc",
            "transcript": "Some text",
            "message": "What is this about?",
            "history": [],
        })
        assert resp.status_code == 200
        assert resp.json()["reply"] == "This is the answer"

    @patch("api.v1.endpoints.chat_with_transcript", new_callable=AsyncMock)
    def test_chat_with_history(self, mock_chat):
        mock_chat.return_value = "Follow up answer"

        resp = client.post("/api/v1/chat", json={
            "video_id": "abc",
            "transcript": "Some text",
            "message": "Tell me more",
            "history": [
                {"role": "user", "content": "What is this?"},
                {"role": "assistant", "content": "This is about..."},
            ],
        })
        assert resp.status_code == 200
        assert resp.json()["reply"] == "Follow up answer"

    @patch("api.v1.endpoints.chat_with_transcript", new_callable=AsyncMock)
    def test_chat_error(self, mock_chat):
        mock_chat.side_effect = RuntimeError("API error")

        resp = client.post("/api/v1/chat", json={
            "video_id": "abc",
            "transcript": "text",
            "message": "hi",
        })
        assert resp.status_code == 500
