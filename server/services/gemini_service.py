from functools import lru_cache

from google import genai

from config import GEMINI_API_KEY

MODEL = "gemini-2.5-flash"


@lru_cache(maxsize=1)
def _get_client() -> genai.Client:
    return genai.Client(api_key=GEMINI_API_KEY)

SUMMARY_PROMPT = """당신은 YouTube 영상 내용을 정리하는 전문가입니다.
아래 자막을 읽고 한국어로 요약해주세요.

## 규칙
- 핵심 내용을 bullet point로 정리
- 주요 포인트를 3~7개로 압축
- 각 포인트는 1~2문장
- 영상의 맥락과 흐름을 유지

## 영상 제목
{title}

## 자막
{transcript}
"""

CHAT_SYSTEM = """당신은 YouTube 영상 내용에 대해 답변하는 AI 어시스턴트입니다.
아래 영상의 자막과 요약을 참고하여 사용자 질문에 한국어로 답변하세요.

## 영상 제목
{title}

## 요약
{summary}

## 자막
{transcript}
"""


def summarize_transcript(transcript: str, video_title: str) -> str:
    prompt = SUMMARY_PROMPT.format(title=video_title, transcript=transcript)
    response = _get_client().models.generate_content(model=MODEL, contents=prompt)
    return response.text


def chat(
    transcript: str,
    summary: str,
    video_title: str,
    message: str,
    history: list[dict],
) -> str:
    system_instruction = CHAT_SYSTEM.format(
        title=video_title, summary=summary, transcript=transcript
    )

    contents = [{"role": "user", "parts": [{"text": system_instruction}]}]
    for msg in history:
        role = "user" if msg["role"] == "user" else "model"
        contents.append({"role": role, "parts": [{"text": msg["content"]}]})
    contents.append({"role": "user", "parts": [{"text": message}]})

    response = _get_client().models.generate_content(model=MODEL, contents=contents)
    return response.text
