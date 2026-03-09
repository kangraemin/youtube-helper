from fastapi import APIRouter, HTTPException

from schemas.models import (
    TranscriptRequest,
    TranscriptResponse,
    SummarizeRequest,
    SummarizeResponse,
    ChatRequest,
    ChatResponse,
)
from services.youtube import extract_transcript
from services.summarizer import summarize_transcript
from services.chat import chat_with_transcript

router = APIRouter(prefix="/api/v1")


@router.post("/transcript", response_model=TranscriptResponse)
def get_transcript(request: TranscriptRequest):
    try:
        result = extract_transcript(request.url)
        return TranscriptResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/summarize", response_model=SummarizeResponse)
def get_summary(request: SummarizeRequest):
    try:
        result = summarize_transcript(request.transcript, request.title)
        return SummarizeResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/chat", response_model=ChatResponse)
def get_chat_response(request: ChatRequest):
    try:
        answer = chat_with_transcript(
            request.transcript, request.question, request.history
        )
        return ChatResponse(answer=answer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
