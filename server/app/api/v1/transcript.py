from fastapi import APIRouter

from app.schemas.transcript import TranscriptRequest, TranscriptResponse
from app.services.youtube import extract_video_id, get_thumbnail_url, fetch_video_title
from app.services.transcript import fetch_transcript

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
async def get_transcript(request: TranscriptRequest):
    video_id = extract_video_id(request.url)
    title = await fetch_video_title(video_id)
    segments, language, duration_seconds = fetch_transcript(video_id)
    thumbnail_url = get_thumbnail_url(video_id)
    transcript_text = " ".join(seg.text for seg in segments)

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        thumbnail_url=thumbnail_url,
        duration_seconds=duration_seconds,
        language=language,
        segments=segments,
        transcript_text=transcript_text,
    )
