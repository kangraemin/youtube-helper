import json
import os

import google.generativeai as genai


def _get_model():
    api_key = os.environ.get("GEMINI_API_KEY", "")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel("gemini-2.0-flash")


def summarize(transcript: str) -> dict:
    model = _get_model()
    prompt = f"""다음 YouTube 영상 자막을 분석하여 JSON 형식으로 요약해주세요.

자막:
{transcript}

다음 JSON 형식으로 응답해주세요 (JSON만 출력, 마크다운 코드블록 없이):
{{
    "summary": "영상의 전체 요약 (3-5문장)",
    "key_points": ["핵심 포인트 1", "핵심 포인트 2", "핵심 포인트 3"],
    "action_points": ["실천할 수 있는 포인트 1", "실천할 수 있는 포인트 2"]
}}"""

    response = model.generate_content(prompt)
    text = response.text.strip()
    if text.startswith("```"):
        text = text.split("\n", 1)[1]
        text = text.rsplit("```", 1)[0]
    return json.loads(text)


def chat(transcript: str, message: str, history: list[dict]) -> str:
    model = _get_model()
    prompt_parts = [
        f"다음은 YouTube 영상의 자막입니다:\n{transcript}\n\n",
        "이 영상에 대해 사용자와 대화하세요.\n\n",
    ]

    for msg in history:
        role = "사용자" if msg["role"] == "user" else "AI"
        prompt_parts.append(f"{role}: {msg['content']}\n")

    prompt_parts.append(f"사용자: {message}\nAI:")

    response = model.generate_content("".join(prompt_parts))
    return response.text.strip()
