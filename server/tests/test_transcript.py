from unittest.mock import patch, MagicMock

import pytest

from app.exceptions import TranscriptNotFoundError, VideoNotFoundError
from app.services.transcript import fetch_transcript


class MockSnippet:
    def __init__(self, start, duration, text):
        self.start = start
        self.duration = duration
        self.text = text


class MockFetchedTranscript:
    """Iterable mock for fetched transcript data."""

    def __init__(self, snippets):
        self._snippets = snippets

    def __iter__(self):
        return iter(self._snippets)


class TestFetchTranscript:
    @patch("app.services.transcript.YouTubeTranscriptApi")
    def test_fetch_korean_transcript(self, mock_api_class):
        mock_api = MagicMock()
        mock_api_class.return_value = mock_api

        mock_transcript = MagicMock()
        mock_transcript.language_code = "ko"
        mock_transcript.fetch.return_value = MockFetchedTranscript([
            MockSnippet(0.0, 5.0, "안녕하세요"),
            MockSnippet(5.0, 3.0, "반갑습니다"),
        ])

        mock_transcript_list = MagicMock()
        mock_transcript_list.find_transcript.return_value = mock_transcript
        mock_api.list_transcripts.return_value = mock_transcript_list

        segments, language, duration = fetch_transcript("test123")

        assert language == "ko"
        assert len(segments) == 2
        assert segments[0].text == "안녕하세요"
        assert segments[0].start == 0.0
        assert segments[0].duration == 5.0
        assert duration == 8.0

    @patch("app.services.transcript.YouTubeTranscriptApi")
    def test_fallback_to_english(self, mock_api_class):
        from youtube_transcript_api._errors import NoTranscriptFound

        mock_api = MagicMock()
        mock_api_class.return_value = mock_api

        mock_en_transcript = MagicMock()
        mock_en_transcript.language_code = "en"
        mock_en_transcript.fetch.return_value = MockFetchedTranscript([
            MockSnippet(0.0, 5.0, "Hello"),
        ])

        mock_transcript_list = MagicMock()
        mock_transcript_list.find_transcript.side_effect = [
            NoTranscriptFound("vid", ["ko"], MagicMock()),  # ko fails
            mock_en_transcript,  # en succeeds
        ]
        mock_api.list_transcripts.return_value = mock_transcript_list

        segments, language, duration = fetch_transcript("test123")

        assert language == "en"
        assert len(segments) == 1
        assert segments[0].text == "Hello"

    @patch("app.services.transcript.YouTubeTranscriptApi")
    def test_video_unavailable_raises_404(self, mock_api_class):
        from youtube_transcript_api._errors import VideoUnavailable

        mock_api = MagicMock()
        mock_api_class.return_value = mock_api
        mock_api.list_transcripts.side_effect = VideoUnavailable("test")

        with pytest.raises(VideoNotFoundError):
            fetch_transcript("test123")

    @patch("app.services.transcript.YouTubeTranscriptApi")
    def test_transcripts_disabled_raises_404(self, mock_api_class):
        from youtube_transcript_api._errors import TranscriptsDisabled

        mock_api = MagicMock()
        mock_api_class.return_value = mock_api
        mock_api.list_transcripts.side_effect = TranscriptsDisabled("test")

        with pytest.raises(TranscriptNotFoundError):
            fetch_transcript("test123")
