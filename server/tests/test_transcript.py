from unittest.mock import patch, MagicMock


class TestTranscriptEndpoint:
    def _mock_transcript_api(self, entries, language="ko"):
        mock_transcript = MagicMock()
        mock_transcript.language_code = language
        mock_transcript.fetch.return_value = entries

        mock_transcript_list = MagicMock()
        mock_transcript_list.find_transcript.return_value = mock_transcript

        mock_api_instance = MagicMock()
        mock_api_instance.list.return_value = mock_transcript_list

        return mock_api_instance

    def test_valid_youtube_url(self, client):
        mock_entry = MagicMock()
        mock_entry.text = "안녕하세요 테스트 자막입니다"
        mock_api = self._mock_transcript_api([mock_entry], "ko")

        with patch(
            "app.services.transcript_service.YouTubeTranscriptApi",
            return_value=mock_api,
        ):
            response = client.post(
                "/api/v1/transcript",
                json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"},
            )

        assert response.status_code == 200
        data = response.json()
        assert data["video_id"] == "dQw4w9WgXcQ"
        assert data["transcript"] == "안녕하세요 테스트 자막입니다"
        assert data["language"] == "ko"
        assert data["thumbnail_url"] == "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
        assert data["title"] == "YouTube Video dQw4w9WgXcQ"

    def test_short_youtube_url(self, client):
        mock_entry = MagicMock()
        mock_entry.text = "Hello this is a test"
        mock_api = self._mock_transcript_api([mock_entry], "en")

        with patch(
            "app.services.transcript_service.YouTubeTranscriptApi",
            return_value=mock_api,
        ):
            response = client.post(
                "/api/v1/transcript",
                json={"url": "https://youtu.be/dQw4w9WgXcQ"},
            )

        assert response.status_code == 200
        assert response.json()["video_id"] == "dQw4w9WgXcQ"

    def test_invalid_url(self, client):
        response = client.post(
            "/api/v1/transcript",
            json={"url": "https://example.com/not-youtube"},
        )
        assert response.status_code == 400
        assert "Invalid YouTube URL" in response.json()["detail"]

    def test_no_transcript_available(self, client):
        mock_api = MagicMock()
        mock_api.list.side_effect = Exception("No transcripts found")

        with patch(
            "app.services.transcript_service.YouTubeTranscriptApi",
            return_value=mock_api,
        ):
            response = client.post(
                "/api/v1/transcript",
                json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"},
            )

        assert response.status_code == 404
        assert "Transcript not found" in response.json()["detail"]

    def test_multiple_transcript_entries(self, client):
        entry1 = MagicMock()
        entry1.text = "첫 번째"
        entry2 = MagicMock()
        entry2.text = "두 번째"
        mock_api = self._mock_transcript_api([entry1, entry2], "ko")

        with patch(
            "app.services.transcript_service.YouTubeTranscriptApi",
            return_value=mock_api,
        ):
            response = client.post(
                "/api/v1/transcript",
                json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"},
            )

        assert response.status_code == 200
        assert response.json()["transcript"] == "첫 번째 두 번째"
