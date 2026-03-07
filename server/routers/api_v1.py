from fastapi import APIRouter, HTTPException

from models.schemas import (
    ChatRequest,
    ChatResponse,
    SummarizeRequest,
    SummarizeResponse,
    TranscriptRequest,
    TranscriptResponse,
    TranscriptSegment,
)
from services.gemini_service import chat_about_video, summarize_transcript
from services.transcript_service import extract_video_id, get_transcript, get_video_title

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
async def transcript(request: TranscriptRequest):
    try:
        video_id = extract_video_id(request.url)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid YouTube URL")

    title = get_video_title(video_id)

    try:
        segments, full_text = get_transcript(video_id)
    except Exception:
        raise HTTPException(status_code=404, detail="Transcript not found")

    return TranscriptResponse(
        video_id=video_id,
        title=title,
        transcript=[TranscriptSegment(**seg) for seg in segments],
        full_text=full_text,
    )


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize(request: SummarizeRequest):
    try:
        summary = summarize_transcript(request.title, request.full_text, request.language)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Summarization failed: {str(e)}")

    return SummarizeResponse(video_id=request.video_id, summary=summary)


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    messages = [{"role": msg.role, "content": msg.content} for msg in request.messages]

    try:
        reply = chat_about_video(request.title, request.full_text, messages, request.language)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat failed: {str(e)}")

    return ChatResponse(video_id=request.video_id, reply=reply)
