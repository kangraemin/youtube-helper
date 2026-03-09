"""Gemini AI service for summarization and chat."""

import os
import json
from google import genai
from dotenv import load_dotenv

load_dotenv()

_client = None
_MODEL = "gemini-2.0-flash"


def _get_client():
    global _client
    if _client is None:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable is not set")
        _client = genai.Client(api_key=api_key)
    return _client


def summarize_transcript(transcript: str, title: str = "") -> dict:
    """Summarize a video transcript using Gemini."""
    prompt = f"""다음은 YouTube 영상 "{title}"의 자막입니다. 아래 형식으로 요약해주세요.

반드시 아래 JSON 형식으로만 답변하세요 (마크다운 코드블록 없이):
{{
  "summary": "영상의 핵심 내용을 3-5문장으로 요약",
  "key_points": ["핵심 포인트 1", "핵심 포인트 2", ...],
  "chapters": [
    {{"title": "챕터 제목", "summary": "챕터 요약", "start_time": "0:00"}}
  ]
}}

자막:
{transcript[:8000]}"""

    response = _get_client().models.generate_content(model=_MODEL, contents=prompt)
    text = response.text.strip()

    if text.startswith("```"):
        text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text[:-3]
        text = text.strip()

    try:
        result = json.loads(text)
    except json.JSONDecodeError:
        result = {
            "summary": text,
            "key_points": [],
            "chapters": [],
        }

    return result


def chat_with_transcript(transcript: str, question: str, history: list[dict] = None) -> str:
    """Chat about a video transcript using Gemini."""
    history_text = ""
    if history:
        for msg in history[-10:]:
            role = msg.get("role", "user")
            content = msg.get("content", "")
            history_text += f"\n{role}: {content}"

    prompt = f"""다음은 YouTube 영상의 자막입니다. 사용자의 질문에 자막 내용을 기반으로 답변해주세요.

자막:
{transcript[:8000]}

{f"이전 대화:{history_text}" if history_text else ""}

사용자 질문: {question}

답변:"""

    response = _get_client().models.generate_content(model=_MODEL, contents=prompt)
    return response.text.strip()
