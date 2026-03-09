from fastapi import APIRouter

from app.schemas.summarize import SummarizeRequest, SummarizeResponse
from app.services.gemini import summarize as summarize_transcript
from app.services.youtube import fetch_metadata, fetch_transcript
from app.utils.youtube_parser import extract_video_id

router = APIRouter()


@router.post("/summarize", response_model=SummarizeResponse)
def post_summarize(req: SummarizeRequest):
    video_id = extract_video_id(req.url)
    segments, full_text, language = fetch_transcript(video_id)
    meta = fetch_metadata(video_id)
    result = summarize_transcript(full_text, meta.title)
    return SummarizeResponse(
        video_id=video_id,
        title=meta.title,
        thumbnail_url=meta.thumbnail_url,
        summary=result["summary"],
        key_points=result["key_points"],
        tips=result["tips"],
    )
