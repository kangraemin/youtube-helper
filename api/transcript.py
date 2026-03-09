from urllib.parse import urlparse, parse_qs

import httpx
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from youtube_transcript_api import YouTubeTranscriptApi

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Models ---


class TranscriptRequest(BaseModel):
    url: str


class TranscriptSegment(BaseModel):
    text: str
    start: float
    duration: float


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    transcript: list[TranscriptSegment]
    full_text: str


# --- Transcript logic ---


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
        elif parsed.path.startswith("/live/"):
            video_id = parsed.path.split("/live/")[1].split("/")[0].split("?")[0]
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


# --- Endpoint ---


@app.post("/api/transcript", response_model=TranscriptResponse)
async def transcript(request: TranscriptRequest):
    try:
        video_id = extract_video_id(request.url)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid YouTube URL")

    title = get_video_title(video_id)

    try:
        segments, full_text = get_transcript(video_id)
    except Exception:
        raise HTTPException(status_code=404, detail="Transcript not found")

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        transcript=[TranscriptSegment(**seg) for seg in segments],
        full_text=full_text,
    )
