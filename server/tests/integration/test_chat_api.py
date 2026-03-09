from unittest.mock import patch

from app.schemas.transcript import TranscriptSegment, VideoMeta


class TestChatAPI:
    def _setup_mocks(self):
        segments = [TranscriptSegment(text="Hello", start=0.0, duration=1.0)]
        meta = VideoMeta(
            video_id="dQw4w9WgXcQ",
            title="Test Video",
            thumbnail_url="https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        )
        return segments, meta

    def test_post_chat_success(self, client):
        segments, meta = self._setup_mocks()

        with patch("app.api.v1.chat.extract_video_id", return_value="dQw4w9WgXcQ"), \
             patch("app.api.v1.chat.fetch_transcript", return_value=(segments, "Hello", "ko")), \
             patch("app.api.v1.chat.fetch_metadata", return_value=meta), \
             patch("app.api.v1.chat.chat_with_transcript", return_value="The answer."):
            resp = client.post("/api/v1/chat", json={
                "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                "message": "What is this about?",
            })

        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "dQw4w9WgXcQ"
        assert data["reply"] == "The answer."
        assert len(data["history"]) == 2
        assert data["history"][0]["role"] == "user"
        assert data["history"][1]["role"] == "assistant"

    def test_post_chat_with_history(self, client):
        segments, meta = self._setup_mocks()

        with patch("app.api.v1.chat.extract_video_id", return_value="dQw4w9WgXcQ"), \
             patch("app.api.v1.chat.fetch_transcript", return_value=(segments, "Hello", "ko")), \
             patch("app.api.v1.chat.fetch_metadata", return_value=meta), \
             patch("app.api.v1.chat.chat_with_transcript", return_value="Follow-up answer."):
            resp = client.post("/api/v1/chat", json={
                "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                "message": "Follow-up question",
                "history": [
                    {"role": "user", "content": "First question"},
                    {"role": "assistant", "content": "First answer"},
                ],
            })

        assert resp.status_code == 200
        data = resp.json()
        assert len(data["history"]) == 4

    def test_post_chat_invalid_url(self, client):
        resp = client.post("/api/v1/chat", json={
            "url": "bad-url",
            "message": "question",
        })
        assert resp.status_code == 400
