from fastapi import APIRouter, HTTPException

from server.models.schemas import (
    ChatRequest,
    ChatResponse,
    SummarizeRequest,
    SummarizeResponse,
    TranscriptRequest,
    TranscriptResponse,
)
from server.services import ai, youtube

router = APIRouter(prefix="/api/v1", tags=["v1"])


@router.post("/transcript", response_model=TranscriptResponse)
async def get_transcript(req: TranscriptRequest):
    try:
        video_id = youtube.extract_video_id(req.url)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    title = await youtube.fetch_title(video_id)
    thumbnail_url = youtube.get_thumbnail_url(video_id)

    try:
        transcript = youtube.fetch_transcript(video_id)
    except RuntimeError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        thumbnail_url=thumbnail_url,
        transcript=transcript,
        duration=None,
    )


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize(req: SummarizeRequest):
    try:
        result = await ai.summarize_transcript(req.transcript)
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI 요약 실패: {e}")

    return SummarizeResponse(
        video_id=req.video_id,
        summary=result["summary"],
        key_points=result["key_points"],
    )


@router.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    history = [{"role": m.role, "content": m.content} for m in req.history]
    try:
        result = await ai.chat_with_transcript(req.transcript, req.message, history)
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI 채팅 실패: {e}")

    return ChatResponse(
        answer=result["answer"],
        sources=result["sources"],
    )
