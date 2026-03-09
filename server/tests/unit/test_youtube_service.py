from unittest.mock import MagicMock, patch

import httpx
import pytest

from app.schemas.transcript import TranscriptSegment, VideoMeta
from app.services.youtube import fetch_metadata, fetch_transcript
from app.utils.exceptions import TranscriptNotAvailable


def _make_snippet(text: str, start: float, duration: float):
    s = MagicMock()
    s.text = text
    s.start = start
    s.duration = duration
    return s


def _make_fetched_transcript(snippets, language="ko"):
    ft = MagicMock()
    ft.__iter__ = lambda self: iter(snippets)
    ft.language = language
    return ft


class TestFetchTranscript:
    @patch("app.services.youtube.YouTubeTranscriptApi")
    def test_fetch_transcript_success(self, mock_api_cls):
        snippets = [
            _make_snippet("안녕하세요", 0.0, 2.0),
            _make_snippet("반갑습니다", 2.0, 1.5),
        ]
        mock_api = MagicMock()
        mock_api_cls.return_value = mock_api
        mock_api.fetch.return_value = _make_fetched_transcript(snippets, "ko")

        segments, full_text, lang = fetch_transcript("testid123ab")

        assert len(segments) == 2
        assert isinstance(segments[0], TranscriptSegment)
        assert segments[0].text == "안녕하세요"
        assert "안녕하세요" in full_text
        assert "반갑습니다" in full_text
        assert lang == "ko"

    @patch("app.services.youtube.YouTubeTranscriptApi")
    def test_fetch_transcript_korean_preferred(self, mock_api_cls):
        snippets = [_make_snippet("한국어 자막", 0.0, 1.0)]
        mock_api = MagicMock()
        mock_api_cls.return_value = mock_api
        mock_api.fetch.return_value = _make_fetched_transcript(snippets, "ko")

        fetch_transcript("testid123ab")

        mock_api.fetch.assert_called_once_with("testid123ab", languages=["ko", "en"])

    @patch("app.services.youtube.YouTubeTranscriptApi")
    def test_fetch_transcript_fallback_english(self, mock_api_cls):
        snippets = [_make_snippet("English subtitle", 0.0, 1.0)]
        mock_api = MagicMock()
        mock_api_cls.return_value = mock_api
        mock_api.fetch.return_value = _make_fetched_transcript(snippets, "en")

        segments, full_text, lang = fetch_transcript("testid123ab")

        assert lang == "en"
        assert segments[0].text == "English subtitle"

    @patch("app.services.youtube.YouTubeTranscriptApi")
    def test_fetch_transcript_not_available(self, mock_api_cls):
        mock_api = MagicMock()
        mock_api_cls.return_value = mock_api
        mock_api.fetch.side_effect = Exception("No transcript")

        with pytest.raises(TranscriptNotAvailable):
            fetch_transcript("testid123ab")


class TestFetchMetadata:
    @patch("app.services.youtube.httpx")
    def test_fetch_metadata_success(self, mock_httpx):
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = {
            "title": "Test Video",
            "thumbnail_url": "https://i.ytimg.com/vi/testid123ab/hqdefault.jpg",
        }
        mock_httpx.get.return_value = mock_resp

        meta = fetch_metadata("testid123ab")

        assert isinstance(meta, VideoMeta)
        assert meta.video_id == "testid123ab"
        assert meta.title == "Test Video"
        assert "hqdefault" in meta.thumbnail_url

    @patch("app.services.youtube.httpx")
    def test_fetch_metadata_fallback(self, mock_httpx):
        mock_httpx.get.side_effect = Exception("oEmbed failed")

        meta = fetch_metadata("testid123ab")

        assert meta.video_id == "testid123ab"
        assert meta.title == "testid123ab"
        assert "testid123ab" in meta.thumbnail_url
