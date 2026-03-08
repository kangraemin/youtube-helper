import re
from urllib.parse import parse_qs, urlparse

import httpx
from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str:
    """YouTube URL에서 video_id를 추출한다."""
    parsed = urlparse(url)

    # youtu.be/VIDEO_ID
    if parsed.hostname in ("youtu.be",):
        video_id = parsed.path.lstrip("/")
        if video_id:
            return video_id.split("/")[0]

    # youtube.com/watch?v=VIDEO_ID
    if parsed.hostname in ("www.youtube.com", "youtube.com", "m.youtube.com"):
        if parsed.path == "/watch":
            qs = parse_qs(parsed.query)
            if "v" in qs:
                return qs["v"][0]

        # youtube.com/embed/VIDEO_ID
        embed_match = re.match(r"/embed/([^/?]+)", parsed.path)
        if embed_match:
            return embed_match.group(1)

        # youtube.com/shorts/VIDEO_ID
        shorts_match = re.match(r"/shorts/([^/?]+)", parsed.path)
        if shorts_match:
            return shorts_match.group(1)

    raise ValueError(f"유효하지 않은 YouTube URL: {url}")


def get_thumbnail_url(video_id: str) -> str:
    return f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"


async def fetch_title(video_id: str) -> str:
    """YouTube oEmbed API로 영상 제목을 가져온다."""
    oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(oembed_url)
        if resp.status_code == 200:
            return resp.json().get("title", "제목 없음")
    return "제목 없음"


def fetch_transcript(video_id: str) -> str:
    """youtube-transcript-api로 자막을 추출한다. 한국어 우선, 영어, 자동생성 순."""
    ytt_api = YouTubeTranscriptApi()
    try:
        transcript = ytt_api.fetch(video_id, languages=["ko", "en"])
    except Exception:
        try:
            transcript_list = ytt_api.list(video_id)
            transcript = transcript_list.find_generated_transcript(["ko", "en"])
            transcript = transcript.fetch()
        except Exception as e:
            raise RuntimeError(f"자막을 가져올 수 없습니다: {e}")

    lines = [snippet.text for snippet in transcript.snippets]
    return " ".join(lines)
