from fastapi import APIRouter

from app.schemas.summarize import SummarizeRequest, SummarizeResponse
from app.services.summarize import summarize_transcript

router = APIRouter()


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize(request: SummarizeRequest):
    result = summarize_transcript(request.title, request.transcript_text)
    return SummarizeResponse(
        video_id=request.video_id,
        summary=result["summary"],
        key_points=result["key_points"],
        sections=result["sections"],
    )
