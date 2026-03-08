from fastapi import APIRouter, HTTPException

from server.models.schemas import SummarizeRequest, SummarizeResponse
from server.services.gemini_service import summarize_transcript

router = APIRouter()


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize(request: SummarizeRequest):
    try:
        result = await summarize_transcript(request.video_id, request.transcript)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
