from fastapi import APIRouter

from app.schemas.transcript import TranscriptRequest, TranscriptResponse
from app.services.youtube import fetch_metadata, fetch_transcript
from app.utils.youtube_parser import extract_video_id

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
def post_transcript(req: TranscriptRequest):
    video_id = extract_video_id(req.url)
    segments, full_text, language = fetch_transcript(video_id)
    meta = fetch_metadata(video_id)
    return TranscriptResponse(
        meta=meta,
        segments=segments,
        full_text=full_text,
        language=language,
    )
