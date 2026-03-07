from urllib.parse import urlparse, parse_qs

import httpx
from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str:
    parsed = urlparse(url)

    if parsed.hostname in ("www.youtube.com", "youtube.com", "m.youtube.com"):
        if parsed.path == "/watch":
            qs = parse_qs(parsed.query)
            video_id = qs.get("v", [None])[0]
            if video_id:
                return video_id
        elif parsed.path.startswith("/shorts/"):
            video_id = parsed.path.split("/shorts/")[1].split("/")[0]
            if video_id:
                return video_id

    if parsed.hostname in ("youtu.be", "www.youtu.be"):
        video_id = parsed.path.lstrip("/").split("/")[0]
        if video_id:
            return video_id

    raise ValueError(f"Invalid YouTube URL: {url}")


def get_video_title(video_id: str) -> str:
    try:
        response = httpx.get(
            "https://www.youtube.com/oembed",
            params={"url": f"https://www.youtube.com/watch?v={video_id}", "format": "json"},
            timeout=10,
        )
        response.raise_for_status()
        return response.json()["title"]
    except Exception:
        return "Unknown"


def get_transcript(video_id: str) -> tuple[list[dict], str]:
    ytt_api = YouTubeTranscriptApi()
    transcript = ytt_api.fetch(video_id, languages=["ko", "en"])

    segments = [
        {"text": entry.text, "start": entry.start, "duration": entry.duration}
        for entry in transcript
    ]
    full_text = " ".join(entry.text for entry in transcript)

    return segments, full_text
