from unittest.mock import MagicMock, patch

import pytest

from services.transcript_service import extract_video_id


class TestExtractVideoId:
    def test_watch_url(self):
        assert extract_video_id("https://www.youtube.com/watch?v=dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_watch_url_with_extra_params(self):
        assert extract_video_id("https://www.youtube.com/watch?v=abc123&t=10") == "abc123"

    def test_short_url(self):
        assert extract_video_id("https://youtu.be/dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_shorts_url(self):
        assert extract_video_id("https://www.youtube.com/shorts/dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_mobile_url(self):
        assert extract_video_id("https://m.youtube.com/watch?v=abc123") == "abc123"

    def test_invalid_url(self):
        with pytest.raises(ValueError):
            extract_video_id("not-a-url")

    def test_invalid_youtube_url_no_id(self):
        with pytest.raises(ValueError):
            extract_video_id("https://www.youtube.com/watch")


class TestTranscriptEndpoint:
    def test_invalid_url_returns_400(self, client):
        response = client.post("/api/v1/transcript", json={"url": "not-a-url"})
        assert response.status_code == 400
        assert "Invalid YouTube URL" in response.json()["detail"]

    @patch("routers.api_v1.get_transcript")
    @patch("routers.api_v1.get_video_title")
    def test_valid_url_returns_transcript(self, mock_title, mock_transcript, client):
        mock_title.return_value = "Test Video"
        mock_transcript.return_value = (
            [{"text": "Hello world", "start": 0.0, "duration": 1.5}],
            "Hello world",
        )

        response = client.post(
            "/api/v1/transcript",
            json={"url": "https://www.youtube.com/watch?v=test123"},
        )

        assert response.status_code == 200
        data = response.json()
        assert data["video_id"] == "test123"
        assert data["title"] == "Test Video"
        assert len(data["transcript"]) == 1
        assert data["full_text"] == "Hello world"

    @patch("routers.api_v1.get_transcript")
    @patch("routers.api_v1.get_video_title")
    def test_no_transcript_returns_404(self, mock_title, mock_transcript, client):
        mock_title.return_value = "Test Video"
        mock_transcript.side_effect = Exception("No transcript")

        response = client.post(
            "/api/v1/transcript",
            json={"url": "https://www.youtube.com/watch?v=test123"},
        )

        assert response.status_code == 404
        assert "Transcript not found" in response.json()["detail"]
