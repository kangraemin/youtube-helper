import os

import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY", ""))

model = genai.GenerativeModel("gemini-1.5-flash")


async def summarize_transcript(title: str, transcript: str) -> dict:
    prompt = f"""다음 YouTube 영상의 자막을 분석하여 요약해주세요.

영상 제목: {title}

자막 내용:
{transcript}

다음 형식으로 응답해주세요:
1. **요약**: 영상의 핵심 내용을 3-5문장으로 요약
2. **핵심 포인트**: 중요한 포인트를 3-7개 bullet point로 정리

응답 형식:
요약: (요약 내용)

핵심 포인트:
- (포인트 1)
- (포인트 2)
- (포인트 3)
"""
    response = await model.generate_content_async(prompt)
    text = response.text

    summary = ""
    key_points = []

    lines = text.strip().split("\n")
    in_summary = False
    in_points = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("요약:") or stripped.startswith("**요약**:"):
            in_summary = True
            in_points = False
            summary_part = stripped.split(":", 1)[1].strip() if ":" in stripped else ""
            if summary_part:
                summary = summary_part
            continue
        if stripped.startswith("핵심 포인트") or stripped.startswith("**핵심 포인트"):
            in_summary = False
            in_points = True
            continue
        if in_summary and stripped:
            summary += (" " + stripped) if summary else stripped
        if in_points and stripped.startswith("- "):
            point = stripped[2:].strip()
            if point.startswith("**") and point.endswith("**"):
                point = point[2:-2]
            key_points.append(point)

    if not summary:
        summary = text[:500]
    if not key_points:
        key_points = ["요약 포인트를 추출할 수 없습니다."]

    return {"summary": summary, "key_points": key_points}


async def chat_with_transcript(
    transcript: str, message: str, history: list[dict]
) -> str:
    context = f"""당신은 YouTube 영상 내용에 대해 답변하는 AI 어시스턴트입니다.
다음 영상 자막을 기반으로 사용자의 질문에 답변해주세요.
자막에 없는 내용은 "영상에서 다루지 않은 내용입니다"라고 답변해주세요.

영상 자막:
{transcript[:8000]}
"""
    chat_history = [{"role": "user", "parts": [context]}]
    chat_history.append(
        {"role": "model", "parts": ["네, 영상 내용을 파악했습니다. 질문해주세요."]}
    )

    for msg in history:
        role = "user" if msg.get("role") == "user" else "model"
        chat_history.append({"role": role, "parts": [msg.get("content", "")]})

    chat_history.append({"role": "user", "parts": [message]})

    response = await model.generate_content_async(chat_history)
    return response.text
