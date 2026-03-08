from fastapi import APIRouter, HTTPException

from server.models.schemas import ChatRequest, ChatResponse
from server.services.gemini_service import chat_with_transcript

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        result = await chat_with_transcript(
            request.video_id, request.transcript, request.message, request.history
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
