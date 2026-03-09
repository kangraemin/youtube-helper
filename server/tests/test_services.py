import pytest

from services.youtube import extract_video_id
from models.schemas import (
    TranscriptRequest,
    TranscriptResponse,
    SummarizeRequest,
    SummarizeResponse,
    ChatRequest,
    ChatResponse,
    Section,
)


class TestExtractVideoId:
    def test_standard_url(self):
        url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_short_url(self):
        url = "https://youtu.be/dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_shorts_url(self):
        url = "https://www.youtube.com/shorts/dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_embed_url(self):
        url = "https://www.youtube.com/embed/dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_url_with_extra_params(self):
        url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=120"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_invalid_url_raises(self):
        with pytest.raises(ValueError):
            extract_video_id("https://example.com/page")


class TestSchemas:
    def test_transcript_request(self):
        req = TranscriptRequest(url="https://youtube.com/watch?v=abc")
        assert req.url == "https://youtube.com/watch?v=abc"

    def test_transcript_response(self):
        resp = TranscriptResponse(
            video_id="abc",
            title="Test",
            thumbnail_url="https://img.youtube.com/vi/abc/maxresdefault.jpg",
            transcript="hello world",
            language="en",
        )
        assert resp.video_id == "abc"
        assert resp.title == "Test"

    def test_summarize_request(self):
        req = SummarizeRequest(video_id="abc", transcript="some text")
        assert req.video_id == "abc"

    def test_summarize_response(self):
        resp = SummarizeResponse(
            video_id="abc",
            summary="A summary",
            key_points=["point1", "point2"],
            sections=[Section(title="Intro", content="Introduction")],
        )
        assert len(resp.key_points) == 2
        assert resp.sections[0].title == "Intro"

    def test_chat_request_default_history(self):
        req = ChatRequest(video_id="abc", transcript="text", message="hi")
        assert req.history == []

    def test_chat_response(self):
        resp = ChatResponse(reply="answer")
        assert resp.reply == "answer"
