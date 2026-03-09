import os
import json

import google.generativeai as genai


def _get_model():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY environment variable is not set")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel("gemini-2.0-flash")


async def summarize_transcript(video_id: str, transcript: str) -> dict:
    """Summarize a transcript using Gemini."""
    model = _get_model()

    prompt = f"""다음 YouTube 영상 자막을 분석해서 JSON 형식으로 요약해주세요.

자막:
{transcript}

다음 JSON 형식으로 응답해주세요 (JSON만 출력, 다른 텍스트 없이):
{{
  "summary": "전체 요약 (3-5문장)",
  "key_points": ["핵심 포인트 1", "핵심 포인트 2", "핵심 포인트 3"],
  "sections": [
    {{"title": "섹션 제목", "content": "섹션 내용 요약"}}
  ]
}}"""

    response = model.generate_content(prompt)
    text = response.text.strip()

    # Strip markdown code fence if present
    if text.startswith("```"):
        text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text[:-3].strip()

    data = json.loads(text)

    return {
        "video_id": video_id,
        "summary": data["summary"],
        "key_points": data["key_points"],
        "sections": data.get("sections", []),
    }
