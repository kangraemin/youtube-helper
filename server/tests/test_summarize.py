from unittest.mock import patch


class TestSummarizeEndpoint:
    @patch("routers.api_v1.summarize_transcript")
    def test_summarize_success(self, mock_summarize, client):
        mock_summarize.return_value = "## Overview\nThis is a test summary."

        response = client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "title": "Test Video",
                "full_text": "Hello world transcript",
                "language": "ko",
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert data["video_id"] == "test123"
        assert "test summary" in data["summary"]
        mock_summarize.assert_called_once_with("Test Video", "Hello world transcript", "ko")

    @patch("routers.api_v1.summarize_transcript")
    def test_summarize_failure(self, mock_summarize, client):
        mock_summarize.side_effect = Exception("API error")

        response = client.post(
            "/api/v1/summarize",
            json={
                "video_id": "test123",
                "title": "Test Video",
                "full_text": "Hello world transcript",
            },
        )

        assert response.status_code == 500
        assert "Summarization failed" in response.json()["detail"]


class TestChatEndpoint:
    @patch("routers.api_v1.chat_about_video")
    def test_chat_success(self, mock_chat, client):
        mock_chat.return_value = "The video discusses testing."

        response = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "title": "Test Video",
                "full_text": "Hello world transcript",
                "messages": [{"role": "user", "content": "What is this video about?"}],
                "language": "ko",
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert data["video_id"] == "test123"
        assert "testing" in data["reply"]

    @patch("routers.api_v1.chat_about_video")
    def test_chat_failure(self, mock_chat, client):
        mock_chat.side_effect = Exception("API error")

        response = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "title": "Test Video",
                "full_text": "Hello world transcript",
                "messages": [{"role": "user", "content": "Question"}],
            },
        )

        assert response.status_code == 500
        assert "Chat failed" in response.json()["detail"]

    @patch("routers.api_v1.chat_about_video")
    def test_chat_multiple_messages(self, mock_chat, client):
        mock_chat.return_value = "Follow-up answer."

        response = client.post(
            "/api/v1/chat",
            json={
                "video_id": "test123",
                "title": "Test Video",
                "full_text": "Hello world transcript",
                "messages": [
                    {"role": "user", "content": "First question"},
                    {"role": "assistant", "content": "First answer"},
                    {"role": "user", "content": "Follow-up question"},
                ],
            },
        )

        assert response.status_code == 200
        assert response.json()["reply"] == "Follow-up answer."
