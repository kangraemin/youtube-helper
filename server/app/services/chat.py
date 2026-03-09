import google.generativeai as genai

from app.config import get_settings
from app.exceptions import GeminiError
from app.schemas.chat import ChatMessage

SYSTEM_PROMPT = """당신은 YouTube 영상에 대해 질문에 답하는 도우미입니다.
아래는 영상의 자막입니다. 이 내용을 바탕으로 사용자 질문에 한국어로 답해주세요.

**자막 내용**:
{transcript_text}
"""


def chat_with_transcript(transcript_text: str, messages: list[ChatMessage]) -> str:
    """Chat about a video transcript using Gemini."""
    settings = get_settings()
    if not settings.gemini_api_key:
        raise GeminiError(detail="GEMINI_API_KEY not configured")

    genai.configure(api_key=settings.gemini_api_key)
    model = genai.GenerativeModel(
        settings.gemini_model,
        system_instruction=SYSTEM_PROMPT.format(transcript_text=transcript_text),
    )

    # Build conversation history
    history = []
    for msg in messages[:-1]:  # All except the last one
        role = "user" if msg.role == "user" else "model"
        history.append({"role": role, "parts": [msg.content]})

    try:
        chat = model.start_chat(history=history)
        last_message = messages[-1].content if messages else ""
        response = chat.send_message(last_message)
        return response.text.strip()
    except Exception as exc:
        raise GeminiError(detail=f"Gemini API error: {exc}")
