import re
from urllib.parse import urlparse, parse_qs

import httpx
from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str:
    """Extract video ID from various YouTube URL formats."""
    parsed = urlparse(url)

    if parsed.hostname in ("youtu.be",):
        return parsed.path.lstrip("/")

    if parsed.hostname in ("www.youtube.com", "youtube.com", "m.youtube.com"):
        if parsed.path == "/watch":
            qs = parse_qs(parsed.query)
            if "v" in qs:
                return qs["v"][0]
        if parsed.path.startswith("/shorts/"):
            return parsed.path.split("/shorts/")[1].split("/")[0]
        if parsed.path.startswith("/embed/"):
            return parsed.path.split("/embed/")[1].split("/")[0]

    # Try regex fallback
    match = re.search(r"(?:v=|/)([a-zA-Z0-9_-]{11})", url)
    if match:
        return match.group(1)

    raise ValueError(f"Cannot extract video ID from URL: {url}")


async def get_video_metadata(video_id: str) -> dict:
    """Get video title and thumbnail URL using oEmbed API."""
    oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    async with httpx.AsyncClient() as client:
        resp = await client.get(oembed_url, timeout=10.0)
        resp.raise_for_status()
        data = resp.json()

    return {
        "title": data.get("title", ""),
        "thumbnail_url": f"https://img.youtube.com/vi/{video_id}/maxresdefault.jpg",
    }


def get_transcript(video_id: str) -> dict:
    """Get transcript using youtube-transcript-api."""
    ytt_api = YouTubeTranscriptApi()
    transcript_list = ytt_api.list_transcripts(video_id)

    # Try to get manually created transcript first, then auto-generated
    try:
        transcript = transcript_list.find_manually_created_transcript(["ko", "en"])
    except Exception:
        try:
            transcript = transcript_list.find_generated_transcript(["ko", "en"])
        except Exception:
            # Get whatever is available
            transcript = next(iter(transcript_list))

    fetched = transcript.fetch()
    full_text = " ".join(snippet.text for snippet in fetched)

    return {
        "transcript": full_text,
        "language": transcript.language_code,
    }


async def fetch_transcript_with_metadata(url: str) -> dict:
    """Fetch transcript and metadata for a YouTube URL."""
    video_id = extract_video_id(url)
    metadata = await get_video_metadata(video_id)
    transcript_data = get_transcript(video_id)

    return {
        "video_id": video_id,
        "title": metadata["title"],
        "thumbnail_url": metadata["thumbnail_url"],
        "transcript": transcript_data["transcript"],
        "language": transcript_data["language"],
    }
