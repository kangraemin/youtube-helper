from fastapi import APIRouter, HTTPException

from schemas.chat import ChatRequest, ChatResponse
from services.gemini import chat_with_context

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def post_chat(req: ChatRequest):
    try:
        messages = [{"role": m.role, "content": m.content} for m in req.messages]
        reply = await chat_with_context(req.full_text, messages)
    except Exception:
        raise HTTPException(status_code=500, detail="Chat failed")

    return ChatResponse(
        video_id=req.video_id,
        reply=reply,
    )
