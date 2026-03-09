from fastapi import APIRouter, HTTPException

from models.schemas import TranscriptRequest, TranscriptResponse
from services import youtube_service

router = APIRouter()


@router.post("/api/v1/transcript", response_model=TranscriptResponse)
async def get_transcript(request: TranscriptRequest):
    video_id = youtube_service.extract_video_id(request.url)
    if not video_id:
        raise HTTPException(status_code=400, detail="Invalid YouTube URL")

    try:
        transcript_data = youtube_service.get_transcript(video_id)
    except Exception:
        raise HTTPException(status_code=404, detail="Transcript not found for this video")

    title = youtube_service.get_video_title(video_id)
    transcript_text = " ".join(entry["text"] for entry in transcript_data)
    total_seconds = 0.0
    if transcript_data:
        last = transcript_data[-1]
        total_seconds = last["start"] + last["duration"]
    duration = youtube_service.format_duration(total_seconds)
    thumbnail_url = f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        thumbnail_url=thumbnail_url,
        duration=duration,
        transcript=transcript_text,
    )
