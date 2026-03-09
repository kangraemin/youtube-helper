import json
from unittest.mock import MagicMock, patch

import pytest

from app.services.gemini import chat, summarize
from app.utils.exceptions import AIServiceError


@pytest.fixture(autouse=True)
def mock_settings():
    with patch("app.services.gemini.settings") as s:
        s.gemini_api_key = "test-key"
        yield s


class TestSummarize:
    @patch("app.services.gemini.genai")
    def test_summarize_returns_structured(self, mock_genai):
        expected = {
            "summary": "This is a summary.",
            "key_points": ["point 1", "point 2", "point 3", "point 4", "point 5"],
            "tips": ["tip 1", "tip 2", "tip 3"],
        }
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = json.dumps(expected)
        mock_model.generate_content.return_value = mock_response

        result = summarize("transcript text here", "Video Title")

        assert result["summary"] == expected["summary"]
        assert result["key_points"] == expected["key_points"]
        assert result["tips"] == expected["tips"]

    @patch("app.services.gemini.genai")
    def test_summarize_api_failure(self, mock_genai):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_model.generate_content.side_effect = Exception("API error")

        with pytest.raises(AIServiceError):
            summarize("transcript", "title")


class TestChat:
    @patch("app.services.gemini.genai")
    def test_chat_returns_answer(self, mock_genai):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = "This is the answer."
        mock_model.generate_content.return_value = mock_response

        result = chat("transcript text", "Video Title", "What is this about?", [])

        assert result == "This is the answer."

    @patch("app.services.gemini.genai")
    def test_chat_with_history(self, mock_genai):
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model
        mock_response = MagicMock()
        mock_response.text = "Follow-up answer."
        mock_model.generate_content.return_value = mock_response

        history = [
            {"role": "user", "content": "First question"},
            {"role": "assistant", "content": "First answer"},
        ]
        result = chat("transcript", "title", "Follow-up question", history)

        assert result == "Follow-up answer."
        # Verify history is included in the prompt
        call_args = mock_model.generate_content.call_args
        prompt = call_args[0][0]
        assert "First question" in prompt
        assert "First answer" in prompt
