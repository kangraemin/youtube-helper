import re
from urllib.parse import urlparse, parse_qs

from server.models.schemas import TranscriptResponse


def extract_video_id(url: str) -> str:
    """Extract video ID from YouTube URL."""
    patterns = [
        r'(?:youtube\.com/watch\?v=)([\w-]{11})',
        r'(?:youtu\.be/)([\w-]{11})',
        r'(?:youtube\.com/embed/)([\w-]{11})',
        r'(?:youtube\.com/shorts/)([\w-]{11})',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)

    parsed = urlparse(url)
    if parsed.hostname and 'youtube' in parsed.hostname:
        qs = parse_qs(parsed.query)
        if 'v' in qs:
            return qs['v'][0]

    raise ValueError(f"Invalid YouTube URL: {url}")


async def extract_transcript(url: str) -> TranscriptResponse:
    """Extract transcript and metadata from a YouTube video."""
    video_id = extract_video_id(url)

    try:
        from youtube_transcript_api import YouTubeTranscriptApi
        transcript_list = YouTubeTranscriptApi.get_transcript(video_id)
        transcript_text = " ".join([entry["text"] for entry in transcript_list])
        duration = transcript_list[-1]["start"] + transcript_list[-1].get("duration", 0) if transcript_list else None
    except Exception as e:
        raise ValueError(f"Failed to extract transcript: {e}")

    title = f"YouTube Video {video_id}"
    thumbnail_url = f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        thumbnail_url=thumbnail_url,
        transcript=transcript_text,
        duration=duration,
    )
