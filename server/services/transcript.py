import re
import httpx
from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str:
    patterns = [
        r'(?:v=|\/videos\/|embed\/|youtu\.be\/|\/v\/|\/e\/|watch\?v=|&v=)([^#&?\/\s]{11})',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    raise ValueError(f"Invalid YouTube URL: {url}")


async def fetch_video_metadata(video_id: str) -> dict:
    oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    async with httpx.AsyncClient() as client:
        resp = await client.get(oembed_url)
        resp.raise_for_status()
        data = resp.json()

    return {
        "title": data.get("title", ""),
        "thumbnail_url": f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg",
    }


def get_transcript(video_id: str) -> tuple[str, str]:
    transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)

    transcript = None
    for t in transcript_list:
        if t.language_code in ("ko", "en"):
            transcript = t
            break

    if transcript is None:
        transcript = transcript_list.find_transcript(
            [t.language_code for t in transcript_list]
        )

    entries = transcript.fetch()

    total_seconds = 0
    text_parts = []
    for entry in entries:
        text_parts.append(entry.text)
        end = entry.start + entry.duration
        if end > total_seconds:
            total_seconds = end

    minutes = int(total_seconds) // 60
    seconds = int(total_seconds) % 60
    duration = f"{minutes}:{seconds:02d}"

    full_text = " ".join(text_parts)
    return full_text, duration
