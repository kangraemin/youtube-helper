import re

from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str | None:
    patterns = [
        r'(?:youtube\.com/watch\?.*v=)([a-zA-Z0-9_-]{11})',
        r'(?:youtu\.be/)([a-zA-Z0-9_-]{11})',
        r'(?:youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
        r'(?:youtube\.com/shorts/)([a-zA-Z0-9_-]{11})',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None


def get_transcript(video_id: str) -> tuple[str, str]:
    ytt_api = YouTubeTranscriptApi()
    transcript_list = ytt_api.list(video_id)

    preferred_langs = ['ko', 'en']
    transcript = None
    language = None

    for lang in preferred_langs:
        try:
            transcript = transcript_list.find_transcript([lang])
            language = lang
            break
        except Exception:
            continue

    if transcript is None:
        generated = list(transcript_list)
        if generated:
            transcript = generated[0]
            language = transcript.language_code
        else:
            raise ValueError("No transcript available")

    fetched = transcript.fetch()
    text = " ".join([entry.text for entry in fetched])
    return text, language


def get_video_title(video_id: str) -> str:
    return f"YouTube Video {video_id}"


def get_thumbnail_url(video_id: str) -> str:
    return f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"
