import sys
import os

import pytest
from pydantic import ValidationError

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from schemas.models import (
    TranscriptRequest,
    TranscriptResponse,
    SummarizeRequest,
    SummarizeResponse,
    ChatRequest,
    ChatResponse,
)


class TestTranscriptRequest:
    def test_valid(self):
        req = TranscriptRequest(url="https://www.youtube.com/watch?v=abc123")
        assert req.url == "https://www.youtube.com/watch?v=abc123"

    def test_missing_url(self):
        with pytest.raises(ValidationError):
            TranscriptRequest()


class TestTranscriptResponse:
    def test_valid(self):
        resp = TranscriptResponse(
            video_id="abc123",
            title="Test",
            thumbnail="https://example.com/thumb.jpg",
            transcript="Hello",
        )
        assert resp.video_id == "abc123"
        assert resp.duration == ""

    def test_with_duration(self):
        resp = TranscriptResponse(
            video_id="abc123",
            title="Test",
            thumbnail="https://example.com/thumb.jpg",
            transcript="Hello",
            duration="10:30",
        )
        assert resp.duration == "10:30"

    def test_missing_fields(self):
        with pytest.raises(ValidationError):
            TranscriptResponse(video_id="abc123")


class TestSummarizeRequest:
    def test_valid(self):
        req = SummarizeRequest(
            video_id="abc123", transcript="Hello", title="Test"
        )
        assert req.video_id == "abc123"

    def test_missing_fields(self):
        with pytest.raises(ValidationError):
            SummarizeRequest(video_id="abc123")


class TestSummarizeResponse:
    def test_valid(self):
        resp = SummarizeResponse(
            summary="Summary text", key_points=["a", "b"]
        )
        assert resp.summary == "Summary text"
        assert len(resp.key_points) == 2

    def test_missing_fields(self):
        with pytest.raises(ValidationError):
            SummarizeResponse(summary="test")


class TestChatRequest:
    def test_valid(self):
        req = ChatRequest(
            video_id="abc123",
            transcript="Hello",
            question="What?",
        )
        assert req.history == []

    def test_with_history(self):
        req = ChatRequest(
            video_id="abc123",
            transcript="Hello",
            question="What?",
            history=[{"role": "user", "content": "Hi"}],
        )
        assert len(req.history) == 1

    def test_missing_fields(self):
        with pytest.raises(ValidationError):
            ChatRequest(video_id="abc123")


class TestChatResponse:
    def test_valid(self):
        resp = ChatResponse(answer="The answer")
        assert resp.answer == "The answer"

    def test_missing_fields(self):
        with pytest.raises(ValidationError):
            ChatResponse()
