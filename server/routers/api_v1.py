from fastapi import APIRouter, HTTPException

from models.schemas import (
    ChatRequest,
    ChatResponse,
    SummarizeRequest,
    SummarizeResponse,
    TranscriptRequest,
    TranscriptResponse,
)
from services import gemini_service, transcript_service

router = APIRouter(prefix="/api/v1", tags=["v1"])


@router.get("/health")
async def health():
    return {"status": "ok"}


@router.post("/transcript", response_model=TranscriptResponse)
async def transcript(req: TranscriptRequest):
    try:
        video_id = transcript_service.extract_video_id(req.url)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    try:
        title = await transcript_service.get_video_title(video_id)
        text, source = transcript_service.get_transcript(video_id)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"자막을 가져올 수 없습니다: {e}")

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        transcript=text,
        thumbnail_url=f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg",
        source=source,
    )


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize(req: SummarizeRequest):
    try:
        summary = gemini_service.summarize_transcript(req.transcript, req.video_title)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"요약 실패: {e}")
    return SummarizeResponse(summary=summary)


@router.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    try:
        reply = gemini_service.chat(
            transcript=req.transcript,
            summary=req.summary,
            video_title=req.video_title,
            message=req.message,
            history=[m.model_dump() for m in req.history],
        )
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"채팅 실패: {e}")
    return ChatResponse(reply=reply)
