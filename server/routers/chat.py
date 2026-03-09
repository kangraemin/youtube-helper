from fastapi import APIRouter, HTTPException
from server.schemas import ChatRequest, ChatResponse
from server.services.gemini import chat_with_transcript

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
async def chat_about_video(request: ChatRequest):
    try:
        answer = chat_with_transcript(
            transcript=request.transcript,
            question=request.question,
            history=request.history,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat failed: {e}")

    return ChatResponse(answer=answer)
