from unittest.mock import patch

from app.schemas.transcript import TranscriptSegment, VideoMeta
from app.utils.exceptions import TranscriptNotAvailable


class TestTranscriptAPI:
    def test_post_transcript_success(self, client):
        segments = [
            TranscriptSegment(text="Hello", start=0.0, duration=1.0),
        ]
        meta = VideoMeta(
            video_id="dQw4w9WgXcQ",
            title="Test Video",
            thumbnail_url="https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        )
        with patch("app.api.v1.transcript.extract_video_id", return_value="dQw4w9WgXcQ"), \
             patch("app.api.v1.transcript.fetch_transcript", return_value=(segments, "Hello", "ko")), \
             patch("app.api.v1.transcript.fetch_metadata", return_value=meta):
            resp = client.post("/api/v1/transcript", json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"})

        assert resp.status_code == 200
        data = resp.json()
        assert data["meta"]["video_id"] == "dQw4w9WgXcQ"
        assert data["meta"]["title"] == "Test Video"
        assert len(data["segments"]) == 1
        assert data["full_text"] == "Hello"
        assert data["language"] == "ko"

    def test_post_transcript_invalid_url(self, client):
        resp = client.post("/api/v1/transcript", json={"url": "https://www.google.com"})
        assert resp.status_code == 400

    def test_post_transcript_no_captions(self, client):
        with patch("app.api.v1.transcript.extract_video_id", return_value="dQw4w9WgXcQ"), \
             patch("app.api.v1.transcript.fetch_transcript", side_effect=TranscriptNotAvailable("No captions")), \
             patch("app.api.v1.transcript.fetch_metadata"):
            resp = client.post("/api/v1/transcript", json={"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"})

        assert resp.status_code == 404
