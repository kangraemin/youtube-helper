from unittest.mock import patch, MagicMock

import pytest

from app.exceptions import GeminiError
from app.schemas.chat import ChatMessage
from app.services.chat import chat_with_transcript


class TestChatWithTranscript:
    @patch("app.services.chat.get_settings")
    @patch("app.services.chat.genai")
    def test_successful_chat(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        mock_response = MagicMock()
        mock_response.text = "이 영상은 파이썬에 대한 내용입니다."

        mock_chat = MagicMock()
        mock_chat.send_message.return_value = mock_response

        mock_model = MagicMock()
        mock_model.start_chat.return_value = mock_chat
        mock_genai.GenerativeModel.return_value = mock_model

        messages = [ChatMessage(role="user", content="이 영상은 무엇에 대한 건가요?")]
        result = chat_with_transcript("자막 내용", messages)

        assert result == "이 영상은 파이썬에 대한 내용입니다."

    @patch("app.services.chat.get_settings")
    @patch("app.services.chat.genai")
    def test_multi_turn_chat(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        mock_response = MagicMock()
        mock_response.text = "더 자세한 설명입니다."

        mock_chat = MagicMock()
        mock_chat.send_message.return_value = mock_response

        mock_model = MagicMock()
        mock_model.start_chat.return_value = mock_chat
        mock_genai.GenerativeModel.return_value = mock_model

        messages = [
            ChatMessage(role="user", content="요약해줘"),
            ChatMessage(role="assistant", content="요약입니다"),
            ChatMessage(role="user", content="더 자세히 설명해줘"),
        ]
        result = chat_with_transcript("자막 내용", messages)

        # Verify history was built correctly (all except last message)
        call_args = mock_model.start_chat.call_args
        history = call_args[1]["history"]
        assert len(history) == 2
        assert history[0]["role"] == "user"
        assert history[1]["role"] == "model"

        # Verify last message was sent
        mock_chat.send_message.assert_called_once_with("더 자세히 설명해줘")
        assert result == "더 자세한 설명입니다."

    @patch("app.services.chat.get_settings")
    def test_missing_api_key(self, mock_settings):
        mock_settings.return_value = MagicMock(gemini_api_key="")

        messages = [ChatMessage(role="user", content="질문")]
        with pytest.raises(GeminiError):
            chat_with_transcript("자막", messages)

    @patch("app.services.chat.get_settings")
    @patch("app.services.chat.genai")
    def test_gemini_error(self, mock_genai, mock_settings):
        mock_settings.return_value = MagicMock(
            gemini_api_key="test-key", gemini_model="gemini-2.0-flash"
        )

        mock_chat = MagicMock()
        mock_chat.send_message.side_effect = Exception("API error")

        mock_model = MagicMock()
        mock_model.start_chat.return_value = mock_chat
        mock_genai.GenerativeModel.return_value = mock_model

        messages = [ChatMessage(role="user", content="질문")]
        with pytest.raises(GeminiError):
            chat_with_transcript("자막", messages)
