import os

import google.generativeai as genai


def _get_model():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY environment variable is not set")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel("gemini-2.0-flash")


async def chat_with_transcript(
    video_id: str,
    transcript: str,
    message: str,
    history: list[dict],
) -> str:
    """Chat about a video transcript using Gemini."""
    model = _get_model()

    system_prompt = f"""당신은 YouTube 영상 내용에 대해 답변하는 도우미입니다.
다음 영상 자막을 기반으로 사용자의 질문에 답변해주세요.
자막에 없는 내용은 "영상에서 다루지 않은 내용입니다"라고 답해주세요.

영상 자막:
{transcript}"""

    # Build conversation history
    contents = [system_prompt]
    for msg in history:
        role_prefix = "사용자: " if msg["role"] == "user" else "도우미: "
        contents.append(role_prefix + msg["content"])
    contents.append("사용자: " + message)

    full_prompt = "\n\n".join(contents)
    response = model.generate_content(full_prompt)

    return response.text.strip()
