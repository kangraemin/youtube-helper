from unittest.mock import patch, MagicMock


class TestSummarizeEndpoint:
    def test_successful_summarize(self, client):
        mock_response = MagicMock()
        mock_response.text = """요약: 이 동영상은 Python 프로그래밍에 대한 강의입니다.

**핵심 포인트**:
- Python은 배우기 쉬운 언어입니다
- 다양한 라이브러리가 있습니다
- 웹 개발에 적합합니다"""

        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response

        with patch("app.services.gemini_service.genai.configure"), patch(
            "app.services.gemini_service.genai.GenerativeModel",
            return_value=mock_model,
        ), patch.dict("os.environ", {"GEMINI_API_KEY": "test-key"}):
            response = client.post(
                "/api/v1/summarize",
                json={
                    "video_id": "test123",
                    "transcript": "Python은 프로그래밍 언어입니다. 배우기 쉽고 다양한 용도로 사용됩니다.",
                    "title": "Python 강의",
                },
            )

        assert response.status_code == 200
        data = response.json()
        assert "summary" in data
        assert "key_points" in data
        assert isinstance(data["key_points"], list)
        assert "transcript_preview" in data

    def test_empty_transcript(self, client):
        response = client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "transcript": "",
                "title": "Test",
            },
        )
        assert response.status_code == 400
        assert "empty" in response.json()["detail"].lower()

    def test_whitespace_only_transcript(self, client):
        response = client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "transcript": "   ",
                "title": "Test",
            },
        )
        assert response.status_code == 400

    def test_transcript_preview_truncation(self, client):
        long_transcript = "A" * 300

        mock_response = MagicMock()
        mock_response.text = "요약: 테스트 요약입니다.\n\n핵심 포인트:\n- 포인트 1"

        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response

        with patch("app.services.gemini_service.genai.configure"), patch(
            "app.services.gemini_service.genai.GenerativeModel",
            return_value=mock_model,
        ), patch.dict("os.environ", {"GEMINI_API_KEY": "test-key"}):
            response = client.post(
                "/api/v1/summarize",
                json={
                    "video_id": "test123",
                    "transcript": long_transcript,
                    "title": "Test",
                },
            )

        assert response.status_code == 200
        data = response.json()
        assert data["transcript_preview"].endswith("...")
        assert len(data["transcript_preview"]) == 203
