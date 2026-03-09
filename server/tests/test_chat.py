from unittest.mock import patch, MagicMock


class TestChatEndpoint:
    def test_successful_chat(self, client):
        mock_response = MagicMock()
        mock_response.text = "이 동영상에서는 Python의 기초를 다루고 있습니다."

        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response

        with patch("app.services.gemini_service.genai.configure"), patch(
            "app.services.gemini_service.genai.GenerativeModel",
            return_value=mock_model,
        ), patch.dict("os.environ", {"GEMINI_API_KEY": "test-key"}):
            response = client.post(
                "/api/v1/chat",
                json={
                    "video_id": "test123",
                    "transcript": "Python은 프로그래밍 언어입니다.",
                    "question": "이 동영상은 무엇에 대한 것인가요?",
                    "chat_history": [],
                },
            )

        assert response.status_code == 200
        data = response.json()
        assert "answer" in data
        assert len(data["answer"]) > 0

    def test_chat_with_history(self, client):
        mock_response = MagicMock()
        mock_response.text = "네, Python 3.12 버전에 대해 설명합니다."

        mock_model = MagicMock()
        mock_model.generate_content.return_value = mock_response

        with patch("app.services.gemini_service.genai.configure"), patch(
            "app.services.gemini_service.genai.GenerativeModel",
            return_value=mock_model,
        ), patch.dict("os.environ", {"GEMINI_API_KEY": "test-key"}):
            response = client.post(
                "/api/v1/chat",
                json={
                    "video_id": "test123",
                    "transcript": "Python 3.12의 새로운 기능을 소개합니다.",
                    "question": "어떤 버전인가요?",
                    "chat_history": [
                        {"role": "user", "content": "이 동영상은 무엇에 대한 것인가요?"},
                        {"role": "assistant", "content": "Python에 대한 동영상입니다."},
                    ],
                },
            )

        assert response.status_code == 200
        assert "answer" in response.json()

    def test_empty_question(self, client):
        response = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript": "테스트 자막",
                "question": "",
                "chat_history": [],
            },
        )
        assert response.status_code == 400
        assert "empty" in response.json()["detail"].lower()

    def test_whitespace_only_question(self, client):
        response = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "transcript": "테스트 자막",
                "question": "   ",
                "chat_history": [],
            },
        )
        assert response.status_code == 400
