from fastapi import APIRouter, HTTPException

from app.schemas import ChatRequest, ChatResponse
from app.services.gemini_service import chat_with_transcript

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
def create_chat(request: ChatRequest):
    if not request.question.strip():
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    history = [{"role": m.role, "content": m.content} for m in request.chat_history]
    answer = chat_with_transcript(request.transcript, request.question, history)

    return ChatResponse(answer=answer)
