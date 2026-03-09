from fastapi import APIRouter, HTTPException

from models.schemas import (
    ChatRequest,
    ChatResponse,
    SummarizeRequest,
    SummarizeResponse,
    TranscriptRequest,
    TranscriptResponse,
)
from services.ai import chat_with_transcript, summarize_transcript
from services.transcript import extract_video_id, fetch_video_metadata, get_transcript

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
async def get_transcript_endpoint(request: TranscriptRequest):
    try:
        video_id = extract_video_id(request.url)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    try:
        metadata = await fetch_video_metadata(video_id)
    except Exception:
        metadata = {
            "title": "제목을 가져올 수 없습니다",
            "thumbnail_url": f"https://img.youtube.com/vi/{video_id}/hqdefault.jpg",
        }

    try:
        transcript_text, duration = get_transcript(video_id)
    except Exception as e:
        raise HTTPException(
            status_code=404, detail=f"자막을 찾을 수 없습니다: {str(e)}"
        )

    return TranscriptResponse(
        video_id=video_id,
        title=metadata["title"],
        thumbnail_url=metadata["thumbnail_url"],
        transcript=transcript_text,
        duration=duration,
    )


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize_endpoint(request: SummarizeRequest):
    try:
        result = await summarize_transcript(request.title, request.transcript)
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"요약 생성 실패: {str(e)}"
        )

    return SummarizeResponse(
        video_id=request.video_id,
        summary=result["summary"],
        key_points=result["key_points"],
    )


@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        history = [
            {"role": msg.role, "content": msg.content} for msg in request.history
        ]
        reply = await chat_with_transcript(
            request.transcript, request.message, history
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"채팅 응답 실패: {str(e)}"
        )

    return ChatResponse(reply=reply)
