"""Integration tests for API endpoints."""
import json
from unittest.mock import patch, MagicMock, AsyncMock

import pytest
from fastapi.testclient import TestClient

from main import app


@pytest.fixture
def client():
    return TestClient(app)


class TestTranscriptEndpoint:
    @patch("app.api.v1.transcript.fetch_transcript")
    @patch("app.api.v1.transcript.fetch_video_title", new_callable=AsyncMock)
    @patch("app.api.v1.transcript.extract_video_id")
    def test_successful_transcript(self, mock_extract, mock_title, mock_fetch, client):
        from app.schemas.transcript import Segment

        mock_extract.return_value = "dQw4w9WgXcQ"
        mock_title.return_value = "테스트 영상"
        mock_fetch.return_value = (
            [Segment(start=0.0, duration=5.0, text="안녕하세요")],
            "ko",
            5.0,
        )

        resp = client.post("/api/v1/transcript", json={"url": "https://youtu.be/dQw4w9WgXcQ"})
        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "dQw4w9WgXcQ"
        assert data["title"] == "테스트 영상"
        assert data["language"] == "ko"
        assert len(data["segments"]) == 1
        assert data["transcript_text"] == "안녕하세요"
        assert data["thumbnail_url"] == "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"

    @patch("app.api.v1.transcript.extract_video_id")
    def test_invalid_url_returns_400(self, mock_extract, client):
        from app.exceptions import InvalidURLError

        mock_extract.side_effect = InvalidURLError()

        resp = client.post("/api/v1/transcript", json={"url": "not-a-url"})
        assert resp.status_code == 400

    @patch("app.api.v1.transcript.fetch_transcript")
    @patch("app.api.v1.transcript.fetch_video_title", new_callable=AsyncMock)
    @patch("app.api.v1.transcript.extract_video_id")
    def test_transcript_not_found_returns_404(self, mock_extract, mock_title, mock_fetch, client):
        from app.exceptions import TranscriptNotFoundError

        mock_extract.return_value = "dQw4w9WgXcQ"
        mock_title.return_value = "제목"
        mock_fetch.side_effect = TranscriptNotFoundError()

        resp = client.post("/api/v1/transcript", json={"url": "https://youtu.be/dQw4w9WgXcQ"})
        assert resp.status_code == 404


class TestSummarizeEndpoint:
    @patch("app.api.v1.summarize.summarize_transcript")
    def test_successful_summarize(self, mock_summarize, client):
        from app.schemas.summarize import Section

        mock_summarize.return_value = {
            "summary": "요약입니다",
            "key_points": ["포인트 1"],
            "sections": [Section(title="섹션", content="내용")],
        }

        resp = client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "title": "테스트",
                "transcript_text": "자막 내용",
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "test123"
        assert data["summary"] == "요약입니다"
        assert len(data["key_points"]) == 1
        assert len(data["sections"]) == 1

    @patch("app.api.v1.summarize.summarize_transcript")
    def test_gemini_error_returns_502(self, mock_summarize, client):
        from app.exceptions import GeminiError

        mock_summarize.side_effect = GeminiError()

        resp = client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "title": "테스트",
                "transcript_text": "자막",
            },
        )
        assert resp.status_code == 502


class TestChatEndpoint:
    @patch("app.api.v1.chat.chat_with_transcript")
    def test_successful_chat(self, mock_chat, client):
        mock_chat.return_value = "답변입니다"

        resp = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript_text": "자막 내용",
                "messages": [{"role": "user", "content": "질문합니다"}],
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["reply"] == "답변입니다"

    @patch("app.api.v1.chat.chat_with_transcript")
    def test_gemini_error_returns_502(self, mock_chat, client):
        from app.exceptions import GeminiError

        mock_chat.side_effect = GeminiError()

        resp = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript_text": "자막",
                "messages": [{"role": "user", "content": "질문"}],
            },
        )
        assert resp.status_code == 502
