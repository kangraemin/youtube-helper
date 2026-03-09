from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api._errors import (
    NoTranscriptFound,
    TranscriptsDisabled,
    VideoUnavailable,
)

from app.exceptions import TranscriptNotFoundError, VideoNotFoundError
from app.schemas.transcript import Segment


def fetch_transcript(video_id: str) -> tuple[list[Segment], str, float]:
    """Fetch transcript for a video. Returns (segments, language, duration_seconds)."""
    try:
        ytt_api = YouTubeTranscriptApi()
        transcript_list = ytt_api.list_transcripts(video_id)
    except VideoUnavailable:
        raise VideoNotFoundError()
    except (TranscriptsDisabled, Exception) as exc:
        if "TranscriptsDisabled" in type(exc).__name__:
            raise TranscriptNotFoundError()
        raise TranscriptNotFoundError(detail=str(exc))

    # Try Korean first, then English, then any available
    transcript = None
    language = ""
    try:
        transcript = transcript_list.find_transcript(["ko"])
        language = "ko"
    except NoTranscriptFound:
        try:
            transcript = transcript_list.find_transcript(["en"])
            language = "en"
        except NoTranscriptFound:
            # Try first available
            try:
                for t in transcript_list:
                    transcript = t
                    language = t.language_code
                    break
            except Exception:
                pass

    if transcript is None:
        raise TranscriptNotFoundError()

    fetched = transcript.fetch()
    segments = []
    duration_seconds = 0.0
    for entry in fetched:
        seg = Segment(
            start=entry.start,
            duration=entry.duration,
            text=entry.text,
        )
        segments.append(seg)
        end = entry.start + entry.duration
        if end > duration_seconds:
            duration_seconds = end

    return segments, language, duration_seconds
