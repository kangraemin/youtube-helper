import re
from urllib.parse import urlparse, parse_qs

import httpx
from youtube_transcript_api import YouTubeTranscriptApi


def _parse_video_id(url: str) -> str:
    parsed = urlparse(url)
    if parsed.hostname in ("youtu.be",):
        return parsed.path.lstrip("/")
    if parsed.hostname in ("www.youtube.com", "youtube.com"):
        qs = parse_qs(parsed.query)
        if "v" in qs:
            return qs["v"][0]
    raise ValueError(f"Cannot parse video ID from URL: {url}")


def _fetch_video_metadata(video_id: str) -> dict:
    try:
        resp = httpx.get(
            f"https://www.youtube.com/watch?v={video_id}",
            headers={"Accept-Language": "ko,en;q=0.9"},
            timeout=10,
        )
        html = resp.text
        title_match = re.search(r'<meta\s+property="og:title"\s+content="([^"]*)"', html)
        thumb_match = re.search(r'<meta\s+property="og:image"\s+content="([^"]*)"', html)
        title = title_match.group(1) if title_match else video_id
        thumbnail = thumb_match.group(1) if thumb_match else f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"
        return {"title": title, "thumbnail": thumbnail}
    except Exception:
        return {
            "title": video_id,
            "thumbnail": f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg",
        }


def extract_transcript(url: str) -> dict:
    video_id = _parse_video_id(url)
    metadata = _fetch_video_metadata(video_id)

    try:
        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
        try:
            transcript_obj = transcript_list.find_transcript(["ko", "en"])
        except Exception:
            transcript_obj = next(iter(transcript_list))
        fetched = transcript_obj.fetch()
        lines = [entry["text"] for entry in fetched]
        transcript_text = " ".join(lines)
    except Exception as e:
        raise RuntimeError(f"Failed to fetch transcript: {e}")

    return {
        "video_id": video_id,
        "title": metadata["title"],
        "thumbnail": metadata["thumbnail"],
        "transcript": transcript_text,
        "duration": "",
    }
