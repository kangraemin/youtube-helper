from fastapi import APIRouter

from app.schemas.chat import ChatMessage, ChatRequest, ChatResponse
from app.services.gemini import chat as chat_with_transcript
from app.services.youtube import fetch_metadata, fetch_transcript
from app.utils.youtube_parser import extract_video_id

router = APIRouter()


@router.post("/chat", response_model=ChatResponse)
def post_chat(req: ChatRequest):
    video_id = extract_video_id(req.url)
    segments, full_text, language = fetch_transcript(video_id)
    meta = fetch_metadata(video_id)
    history_dicts = [{"role": m.role, "content": m.content} for m in req.history]
    reply = chat_with_transcript(full_text, meta.title, req.message, history_dicts)
    new_history = list(req.history) + [
        ChatMessage(role="user", content=req.message),
        ChatMessage(role="assistant", content=reply),
    ]
    return ChatResponse(
        video_id=video_id,
        reply=reply,
        history=new_history,
    )
