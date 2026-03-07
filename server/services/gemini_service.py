import os

from google import genai
from google.genai import types

_client = None
MODEL = "gemini-2.0-flash"


def _get_client() -> genai.Client:
    global _client
    if _client is None:
        _client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
    return _client


def summarize_transcript(title: str, full_text: str, language: str = "ko") -> str:
    lang_instruction = "한국어로" if language == "ko" else f"in {language}"

    response = _get_client().models.generate_content(
        model=MODEL,
        contents=full_text,
        config=types.GenerateContentConfig(
            system_instruction=(
                f"You are a YouTube video summarizer. Summarize the following video transcript {lang_instruction}.\n\n"
                f"Video title: {title}\n\n"
                "Provide a structured summary with:\n"
                "1. **Overview**: A brief 2-3 sentence overview\n"
                "2. **Key Points**: Bullet points of the main takeaways\n"
                "3. **Detailed Summary**: A more detailed summary organized by topic\n\n"
                "Use markdown formatting."
            ),
            temperature=0.3,
        ),
    )

    return response.text


def chat_about_video(
    title: str, full_text: str, messages: list[dict], language: str = "ko"
) -> str:
    lang_instruction = "한국어로 답변해주세요." if language == "ko" else f"Answer in {language}."

    system_instruction = (
        f"You are a helpful assistant that answers questions about a YouTube video.\n\n"
        f"Video title: {title}\n\n"
        f"Video transcript:\n{full_text}\n\n"
        f"Based on the video content, answer the user's questions. {lang_instruction}"
    )

    contents = []
    for msg in messages:
        contents.append(
            types.Content(
                role="user" if msg["role"] == "user" else "model",
                parts=[types.Part.from_text(text=msg["content"])],
            )
        )

    response = _get_client().models.generate_content(
        model=MODEL,
        contents=contents,
        config=types.GenerateContentConfig(
            system_instruction=system_instruction,
            temperature=0.7,
        ),
    )

    return response.text
