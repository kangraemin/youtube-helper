import re
import asyncio
from urllib.parse import urlparse, parse_qs

import requests
from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str | None:
    """Extract video ID from various YouTube URL formats."""
    parsed = urlparse(url)
    hostname = parsed.hostname or ""

    # youtu.be/VIDEO_ID
    if hostname in ("youtu.be", "www.youtu.be"):
        video_id = parsed.path.lstrip("/")
        return video_id if video_id else None

    # youtube.com variants
    if hostname not in ("youtube.com", "www.youtube.com", "m.youtube.com"):
        return None

    path = parsed.path

    # /watch?v=VIDEO_ID
    if path == "/watch":
        qs = parse_qs(parsed.query)
        ids = qs.get("v")
        return ids[0] if ids else None

    # /embed/VIDEO_ID
    match = re.match(r"^/embed/([^/?]+)", path)
    if match:
        return match.group(1)

    # /shorts/VIDEO_ID
    match = re.match(r"^/shorts/([^/?]+)", path)
    if match:
        return match.group(1)

    return None


def fetch_title(video_id: str) -> str:
    """Fetch video title using YouTube oEmbed API."""
    url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    resp = requests.get(url, timeout=10)
    if resp.status_code == 200:
        return resp.json().get("title", "Unknown")
    return "Unknown"


async def get_transcript(video_id: str) -> tuple[list[dict], str, str]:
    """Fetch transcript and metadata. Returns (segments, full_text, title)."""
    ytt_api = YouTubeTranscriptApi()

    snippets = await asyncio.to_thread(ytt_api.fetch, video_id)
    title = await asyncio.to_thread(fetch_title, video_id)

    segments = []
    texts = []
    for s in snippets:
        segments.append({
            "text": s.text,
            "start": s.start,
            "duration": s.duration,
        })
        texts.append(s.text)

    full_text = " ".join(texts)
    return segments, full_text, title
