from unittest.mock import patch

from app.schemas.transcript import TranscriptSegment, VideoMeta
from app.utils.exceptions import AIServiceError


class TestSummarizeAPI:
    def test_post_summarize_success(self, client):
        segments = [TranscriptSegment(text="Hello", start=0.0, duration=1.0)]
        meta = VideoMeta(
            video_id="dQw4w9WgXcQ",
            title="Test Video",
            thumbnail_url="https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        )
        summary_data = {
            "summary": "A summary.",
            "key_points": ["p1", "p2", "p3", "p4", "p5"],
            "tips": ["t1", "t2", "t3"],
        }

        with patch("app.api.v1.summarize.extract_video_id", return_value="dQw4w9WgXcQ"), \
             patch("app.api.v1.summarize.fetch_transcript", return_value=(segments, "Hello", "ko")), \
             patch("app.api.v1.summarize.fetch_metadata", return_value=meta), \
             patch("app.api.v1.summarize.summarize_transcript", return_value=summary_data):
            resp = client.post("/api/v1/summarize", json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"})

        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "dQw4w9WgXcQ"
        assert data["title"] == "Test Video"
        assert data["summary"] == "A summary."
        assert len(data["key_points"]) == 5
        assert len(data["tips"]) == 3

    def test_post_summarize_invalid_url(self, client):
        resp = client.post("/api/v1/summarize", json={"url": "not-a-url"})
        assert resp.status_code == 400

    def test_post_summarize_gemini_failure(self, client):
        segments = [TranscriptSegment(text="Hello", start=0.0, duration=1.0)]
        meta = VideoMeta(
            video_id="dQw4w9WgXcQ",
            title="Test Video",
            thumbnail_url="https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        )

        with patch("app.api.v1.summarize.extract_video_id", return_value="dQw4w9WgXcQ"), \
             patch("app.api.v1.summarize.fetch_transcript", return_value=(segments, "Hello", "ko")), \
             patch("app.api.v1.summarize.fetch_metadata", return_value=meta), \
             patch("app.api.v1.summarize.summarize_transcript", side_effect=AIServiceError("Gemini failed")):
            resp = client.post("/api/v1/summarize", json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"})

        assert resp.status_code == 502
