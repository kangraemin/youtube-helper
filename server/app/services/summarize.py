import json

import google.generativeai as genai

from app.config import get_settings
from app.exceptions import GeminiError
from app.schemas.summarize import Section

SUMMARIZE_PROMPT = """당신은 YouTube 영상 요약 전문가입니다.
아래 영상 제목과 자막을 바탕으로 한국어로 요약해주세요.

**영상 제목**: {title}

**자막 내용**:
{transcript_text}

다음 JSON 형식으로 응답해주세요 (JSON만 출력, 다른 텍스트 없이):
{{
  "summary": "전체 요약 (3-5문장)",
  "key_points": ["핵심 포인트 1", "핵심 포인트 2", ...],
  "sections": [
    {{"title": "섹션 제목", "content": "섹션 내용"}},
    ...
  ]
}}
"""


def summarize_transcript(title: str, transcript_text: str) -> dict:
    """Summarize transcript using Gemini."""
    settings = get_settings()
    if not settings.gemini_api_key:
        raise GeminiError(detail="GEMINI_API_KEY not configured")

    genai.configure(api_key=settings.gemini_api_key)
    model = genai.GenerativeModel(settings.gemini_model)

    prompt = SUMMARIZE_PROMPT.format(title=title, transcript_text=transcript_text)

    try:
        response = model.generate_content(prompt)
        text = response.text.strip()
        # Strip markdown code fences if present
        if text.startswith("```"):
            lines = text.split("\n")
            # Remove first and last lines (```json and ```)
            lines = [l for l in lines if not l.strip().startswith("```")]
            text = "\n".join(lines)
        result = json.loads(text)
        return {
            "summary": result.get("summary", ""),
            "key_points": result.get("key_points", []),
            "sections": [
                Section(title=s.get("title", ""), content=s.get("content", ""))
                for s in result.get("sections", [])
            ],
        }
    except json.JSONDecodeError as exc:
        raise GeminiError(detail=f"Failed to parse Gemini response: {exc}")
    except Exception as exc:
        raise GeminiError(detail=f"Gemini API error: {exc}")
