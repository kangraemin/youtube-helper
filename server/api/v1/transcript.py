from fastapi import APIRouter, HTTPException

from schemas.transcript import TranscriptRequest, TranscriptResponse
from services.youtube import extract_video_id, get_transcript

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
async def post_transcript(req: TranscriptRequest):
    video_id = extract_video_id(req.url)
    if not video_id:
        raise HTTPException(status_code=400, detail="Invalid YouTube URL")

    try:
        segments, full_text, title = await get_transcript(video_id)
    except Exception:
        raise HTTPException(status_code=404, detail="Transcript not found")

    thumbnail_url = f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg"

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        thumbnail_url=thumbnail_url,
        transcript=segments,
        full_text=full_text,
        language="ko",
    )
