from fastapi import APIRouter, HTTPException

from models.schemas import (
    TranscriptRequest,
    TranscriptResponse,
    SummarizeRequest,
    SummarizeResponse,
    ChatRequest,
    ChatResponse,
)
from services.youtube import fetch_transcript_with_metadata
from services.summarizer import summarize_transcript
from services.chat import chat_with_transcript

router = APIRouter(prefix="/api/v1")


@router.post("/transcript", response_model=TranscriptResponse)
async def transcript(request: TranscriptRequest):
    try:
        result = await fetch_transcript_with_metadata(request.url)
        return TranscriptResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize(request: SummarizeRequest):
    try:
        result = await summarize_transcript(request.video_id, request.transcript)
        return SummarizeResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        history = [{"role": m.role, "content": m.content} for m in request.history]
        reply = await chat_with_transcript(
            request.video_id, request.transcript, request.message, history
        )
        return ChatResponse(reply=reply)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
