import json
import os

import google.generativeai as genai


def _get_model():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY 환경변수가 설정되지 않았습니다.")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel("gemini-2.0-flash")


async def summarize_transcript(transcript: str) -> dict:
    """자막 텍스트를 요약하고 핵심 요점을 추출한다."""
    model = _get_model()
    prompt = f"""다음 YouTube 동영상 자막을 분석하여 JSON 형식으로 응답해주세요.

자막:
{transcript}

다음 JSON 형식으로만 응답하세요 (다른 텍스트 없이):
{{
  "summary": "동영상 내용을 3-5문장으로 요약",
  "key_points": ["핵심 요점 1", "핵심 요점 2", "핵심 요점 3"]
}}"""

    response = model.generate_content(prompt)
    text = response.text.strip()

    # JSON 블록 추출
    if "```json" in text:
        text = text.split("```json")[1].split("```")[0].strip()
    elif "```" in text:
        text = text.split("```")[1].split("```")[0].strip()

    result = json.loads(text)
    return {
        "summary": result.get("summary", ""),
        "key_points": result.get("key_points", []),
    }


async def chat_with_transcript(
    transcript: str, message: str, history: list[dict]
) -> dict:
    """자막 기반으로 사용자 질문에 답변한다."""
    model = _get_model()

    history_text = ""
    for msg in history:
        role = "사용자" if msg["role"] == "user" else "AI"
        history_text += f"{role}: {msg['content']}\n"

    prompt = f"""다음은 YouTube 동영상의 자막입니다. 이 자막 내용을 바탕으로 사용자의 질문에 답변해주세요.

자막:
{transcript}

{f"대화 기록:{chr(10)}{history_text}" if history_text else ""}
사용자 질문: {message}

자막 내용을 기반으로 정확하게 답변해주세요. 자막에 없는 내용은 "자막에서 해당 내용을 찾을 수 없습니다"라고 답변해주세요."""

    response = model.generate_content(prompt)
    return {
        "answer": response.text.strip(),
        "sources": [],
    }
