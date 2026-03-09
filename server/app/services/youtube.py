import httpx
from youtube_transcript_api import YouTubeTranscriptApi

from app.schemas.transcript import TranscriptSegment, VideoMeta
from app.utils.exceptions import TranscriptNotAvailable


def fetch_transcript(video_id: str) -> tuple[list[TranscriptSegment], str, str]:
    try:
        api = YouTubeTranscriptApi()
        fetched = api.fetch(video_id, languages=["ko", "en"])
        segments = [
            TranscriptSegment(text=s.text, start=s.start, duration=s.duration)
            for s in fetched
        ]
        full_text = " ".join(seg.text for seg in segments)
        language = fetched.language
        return segments, full_text, language
    except Exception as e:
        raise TranscriptNotAvailable(f"Transcript not available for {video_id}: {e}")


def fetch_metadata(video_id: str) -> VideoMeta:
    try:
        url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
        resp = httpx.get(url, timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            return VideoMeta(
                video_id=video_id,
                title=data.get("title", video_id),
                thumbnail_url=data.get(
                    "thumbnail_url",
                    f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg",
                ),
            )
    except Exception:
        pass

    return VideoMeta(
        video_id=video_id,
        title=video_id,
        thumbnail_url=f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg",
    )
