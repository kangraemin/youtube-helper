from fastapi import APIRouter

from app.schemas.chat import ChatRequest, ChatResponse
from app.services.chat import chat_with_transcript

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    reply = chat_with_transcript(request.transcript_text, request.messages)
    return ChatResponse(reply=reply)
