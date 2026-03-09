from fastapi import APIRouter, HTTPException

from app.schemas import TranscriptRequest, TranscriptResponse
from app.services.transcript_service import (
    extract_video_id,
    get_transcript,
    get_thumbnail_url,
    get_video_title,
)

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
def create_transcript(request: TranscriptRequest):
    video_id = extract_video_id(request.url)
    if not video_id:
        raise HTTPException(status_code=400, detail="Invalid YouTube URL")

    try:
        transcript, language = get_transcript(video_id)
    except Exception:
        raise HTTPException(status_code=404, detail="Transcript not found")

    title = get_video_title(video_id)
    thumbnail_url = get_thumbnail_url(video_id)

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        thumbnail_url=thumbnail_url,
        duration="",
        transcript=transcript,
        language=language,
    )
