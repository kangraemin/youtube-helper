import json
from unittest.mock import patch, MagicMock

import pytest

from app.exceptions import GeminiError
from app.services.summarize import summarize_transcript


class TestSummarizeTranscript:
    @patch("app.services.summarize.get_settings")
    @patch("app.services.summarize.genai")
    def test_successful_summarize(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        expected = {
            "summary": "이 영상은 테스트입니다.",
            "key_points": ["포인트 1", "포인트 2"],
            "sections": [{"title": "섹션 1", "content": "내용 1"}],
        }

        mock_response = MagicMock()
        mock_response.text = json.dumps(expected)
        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response
        mock_genai.GenerativeModel.return_value = mock_model

        result = summarize_transcript("테스트 제목", "자막 내용입니다")

        assert result["summary"] == "이 영상은 테스트입니다."
        assert len(result["key_points"]) == 2
        assert len(result["sections"]) == 1
        assert result["sections"][0].title == "섹션 1"

    @patch("app.services.summarize.get_settings")
    def test_missing_api_key_raises_502(self, mock_settings):
        mock_settings.return_value = MagicMock(gemini_api_key="")

        with pytest.raises(GeminiError):
            summarize_transcript("제목", "자막")

    @patch("app.services.summarize.get_settings")
    @patch("app.services.summarize.genai")
    def test_invalid_json_response_raises_502(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        mock_response = MagicMock()
        mock_response.text = "This is not JSON"
        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response
        mock_genai.GenerativeModel.return_value = mock_model

        with pytest.raises(GeminiError):
            summarize_transcript("제목", "자막")

    @patch("app.services.summarize.get_settings")
    @patch("app.services.summarize.genai")
    def test_gemini_exception_raises_502(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        mock_model = MagicMock()
        mock_model.generate_content.side_effect = Exception("API down")
        mock_genai.GenerativeModel.return_value = mock_model

        with pytest.raises(GeminiError):
            summarize_transcript("제목", "자막")

    @patch("app.services.summarize.get_settings")
    @patch("app.services.summarize.genai")
    def test_markdown_fenced_json(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        expected = {
            "summary": "요약입니다",
            "key_points": ["포인트"],
            "sections": [],
        }

        mock_response = MagicMock()
        mock_response.text = f"```json\n{json.dumps(expected)}\n```"
        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response
        mock_genai.GenerativeModel.return_value = mock_model

        result = summarize_transcript("제목", "자막")
        assert result["summary"] == "요약입니다"
