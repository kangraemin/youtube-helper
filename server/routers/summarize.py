from fastapi import APIRouter, HTTPException

from models.schemas import SummarizeRequest, SummarizeResponse
from services import gemini_service

router = APIRouter()


@router.post("/api/v1/summarize", response_model=SummarizeResponse)
async def summarize(request: SummarizeRequest):
    if not request.transcript.strip():
        raise HTTPException(status_code=400, detail="Transcript cannot be empty")

    try:
        result = gemini_service.summarize(request.transcript)
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to generate summary")

    return SummarizeResponse(
        video_id=request.video_id,
        summary=result["summary"],
        key_points=result["key_points"],
        action_points=result["action_points"],
    )
