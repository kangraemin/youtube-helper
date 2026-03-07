import re
from urllib.parse import parse_qs, urlparse

import httpx
from youtube_transcript_api import YouTubeTranscriptApi


def extract_video_id(url: str) -> str:
    """YouTube URL에서 video ID를 추출한다."""
    parsed = urlparse(url)

    if parsed.hostname in ("youtu.be",):
        return parsed.path.lstrip("/")

    if parsed.hostname in ("www.youtube.com", "youtube.com", "m.youtube.com"):
        if parsed.path == "/watch":
            qs = parse_qs(parsed.query)
            if "v" in qs:
                return qs["v"][0]
        if parsed.path.startswith(("/embed/", "/v/", "/shorts/")):
            return parsed.path.split("/")[2]

    raise ValueError(f"Invalid YouTube URL: {url}")


async def get_video_title(video_id: str) -> str:
    """YouTube 페이지에서 영상 제목을 가져온다."""
    url = f"https://www.youtube.com/watch?v={video_id}"
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, headers={"Accept-Language": "ko-KR,ko;q=0.9"})
        resp.raise_for_status()
    match = re.search(r"<title>(.*?)</title>", resp.text)
    if match:
        title = match.group(1).replace(" - YouTube", "").strip()
        return title
    return "제목 없음"


def get_transcript(video_id: str) -> tuple[str, str]:
    """자막을 가져온다. (transcript_text, source) 반환."""
    ytt_api = YouTubeTranscriptApi()
    transcript = ytt_api.fetch(video_id, languages=["ko", "en"])
    lines = [entry.text for entry in transcript.snippets]
    return "\n".join(lines), "youtube-transcript-api"
