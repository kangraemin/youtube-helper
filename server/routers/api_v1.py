from fastapi import APIRouter, HTTPException

from models.schemas import TranscriptRequest, TranscriptResponse, TranscriptSegment
from services.transcript_service import extract_video_id, get_transcript, get_video_title

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
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
