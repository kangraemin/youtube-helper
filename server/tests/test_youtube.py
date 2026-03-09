import pytest

from app.exceptions import InvalidURLError
from app.services.youtube import extract_video_id, get_thumbnail_url


class TestExtractVideoId:
    def test_standard_url(self):
        url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_short_url(self):
        url = "https://youtu.be/dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_shorts_url(self):
        url = "https://youtube.com/shorts/dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_embed_url(self):
        url = "https://youtube.com/embed/dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_url_with_extra_params(self):
        url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=120&list=PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_www_short_url(self):
        url = "https://www.youtube.com/watch?v=abc12345678"
        assert extract_video_id(url) == "abc12345678"

    def test_no_www(self):
        url = "https://youtube.com/watch?v=dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"

    def test_invalid_url_raises(self):
        with pytest.raises(InvalidURLError):
            extract_video_id("https://example.com/not-youtube")

    def test_empty_url_raises(self):
        with pytest.raises(InvalidURLError):
            extract_video_id("")

    def test_none_url_raises(self):
        with pytest.raises(InvalidURLError):
            extract_video_id("   ")

    def test_watch_url_missing_v_param(self):
        with pytest.raises(InvalidURLError):
            extract_video_id("https://www.youtube.com/watch?list=abc")

    def test_http_url(self):
        url = "http://www.youtube.com/watch?v=dQw4w9WgXcQ"
        assert extract_video_id(url) == "dQw4w9WgXcQ"


class TestGetThumbnailUrl:
    def test_thumbnail_url(self):
        result = get_thumbnail_url("dQw4w9WgXcQ")
        assert result == "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
