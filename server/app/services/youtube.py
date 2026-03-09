import re
from urllib.parse import urlparse, parse_qs

import httpx

from app.exceptions import InvalidURLError, VideoNotFoundError

_PATTERNS = [
    # youtu.be/VIDEO_ID
    re.compile(r"^https?://youtu\.be/(?P<id>[a-zA-Z0-9_-]{11})"),
    # youtube.com/watch?v=VIDEO_ID
    re.compile(r"^https?://(?:www\.)?youtube\.com/watch"),
    # youtube.com/shorts/VIDEO_ID
    re.compile(r"^https?://(?:www\.)?youtube\.com/shorts/(?P<id>[a-zA-Z0-9_-]{11})"),
    # youtube.com/embed/VIDEO_ID
    re.compile(r"^https?://(?:www\.)?youtube\.com/embed/(?P<id>[a-zA-Z0-9_-]{11})"),
]


def extract_video_id(url: str) -> str:
    """Extract video ID from various YouTube URL formats."""
    if not url or not url.strip():
        raise InvalidURLError()

    url = url.strip()

    # Try youtu.be
    match = _PATTERNS[0].match(url)
    if match:
        return match.group("id")

    # Try watch?v=
    if _PATTERNS[1].match(url):
        parsed = urlparse(url)
        qs = parse_qs(parsed.query)
        v = qs.get("v")
        if v and len(v[0]) == 11:
            return v[0]
        raise InvalidURLError()

    # Try shorts
    match = _PATTERNS[2].match(url)
    if match:
        return match.group("id")

    # Try embed
    match = _PATTERNS[3].match(url)
    if match:
        return match.group("id")

    raise InvalidURLError()


def get_thumbnail_url(video_id: str) -> str:
    return f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"


async def fetch_video_title(video_id: str, client: httpx.AsyncClient | None = None) -> str:
    """Fetch video title via oembed API."""
    oembed_url = (
        f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    )
    should_close = False
    if client is None:
        client = httpx.AsyncClient()
        should_close = True
    try:
        resp = await client.get(oembed_url, timeout=10)
        if resp.status_code == 404:
            raise VideoNotFoundError()
        if resp.status_code == 401:
            raise VideoNotFoundError(detail="Video is private or unavailable")
        resp.raise_for_status()
        data = resp.json()
        return data.get("title", "")
    except (httpx.HTTPStatusError, httpx.RequestError) as exc:
        if isinstance(exc, httpx.HTTPStatusError) and exc.response.status_code in (401, 404):
            raise VideoNotFoundError()
        raise VideoNotFoundError(detail=str(exc))
    finally:
        if should_close:
            await client.aclose()
