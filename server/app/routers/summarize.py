from fastapi import APIRouter, HTTPException

from app.schemas import SummarizeRequest, SummarizeResponse
from app.services.gemini_service import summarize_transcript

router = APIRouter()


@router.post("/summarize", response_model=SummarizeResponse)
def create_summary(request: SummarizeRequest):
    if not request.transcript.strip():
        raise HTTPException(status_code=400, detail="Transcript cannot be empty")

    result = summarize_transcript(request.title, request.transcript)

    return SummarizeResponse(
        summary=result["summary"],
        key_points=result["key_points"],
        transcript_preview=result["transcript_preview"],
    )
