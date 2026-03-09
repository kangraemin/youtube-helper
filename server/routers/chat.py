from fastapi import APIRouter, HTTPException

from models.schemas import ChatRequest, ChatResponse
from services import gemini_service

router = APIRouter()


@router.post("/api/v1/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    try:
        history = [{"role": m.role, "content": m.content} for m in request.history]
        reply = gemini_service.chat(request.transcript, request.message, history)
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to generate response")

    return ChatResponse(
        video_id=request.video_id,
        reply=reply,
    )
