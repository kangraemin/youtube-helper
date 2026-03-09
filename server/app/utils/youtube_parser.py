import re
from urllib.parse import parse_qs, urlparse

from app.utils.exceptions import InvalidYouTubeURL

_VIDEO_ID_RE = re.compile(r"^[A-Za-z0-9_-]{11}$")


def extract_video_id(url: str) -> str:
    if not url:
        raise InvalidYouTubeURL("URL is empty")

    parsed = urlparse(url)
    video_id: str | None = None

    if parsed.hostname in ("www.youtube.com", "youtube.com", "m.youtube.com"):
        if parsed.path == "/watch":
            qs = parse_qs(parsed.query)
            video_id = qs.get("v", [None])[0]
        elif parsed.path.startswith("/embed/"):
            video_id = parsed.path.split("/embed/")[1].split("/")[0]
        elif parsed.path.startswith("/shorts/"):
            video_id = parsed.path.split("/shorts/")[1].split("/")[0]
    elif parsed.hostname == "youtu.be":
        video_id = parsed.path.lstrip("/").split("/")[0]

    if not video_id or not _VIDEO_ID_RE.match(video_id):
        raise InvalidYouTubeURL(f"Invalid YouTube URL: {url}")

    return video_id
