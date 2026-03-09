import json

import google.generativeai as genai

from app.config import settings
from app.utils.exceptions import AIServiceError

_MODEL_NAME = "gemini-2.0-flash"

_SUMMARIZE_PROMPT = """You are a YouTube video summarizer. Given the transcript and title, produce a JSON object with:
- "summary": a concise summary in 3-5 sentences
- "key_points": a list of 5-7 key points
- "tips": a list of 3-5 actionable tips or takeaways

Title: {title}

Transcript:
{transcript}

Respond ONLY with valid JSON."""

_CHAT_SYSTEM = """You are a helpful assistant that answers questions about a YouTube video.
Use the transcript and title below to answer the user's question accurately.

Title: {title}

Transcript:
{transcript}
"""


def _configure():
    if not settings.gemini_api_key:
        raise AIServiceError("GEMINI_API_KEY is not configured")
    genai.configure(api_key=settings.gemini_api_key)


def summarize(transcript: str, title: str) -> dict:
    try:
        _configure()
        model = genai.GenerativeModel(
            _MODEL_NAME,
            generation_config={"response_mime_type": "application/json"},
        )
        prompt = _SUMMARIZE_PROMPT.format(title=title, transcript=transcript)
        response = model.generate_content(prompt)
        result = json.loads(response.text)
        return {
            "summary": result.get("summary", ""),
            "key_points": result.get("key_points", []),
            "tips": result.get("tips", []),
        }
    except json.JSONDecodeError as e:
        raise AIServiceError(f"Failed to parse AI response: {e}")
    except AIServiceError:
        raise
    except Exception as e:
        raise AIServiceError(f"AI service error: {e}")


def chat(transcript: str, title: str, message: str, history: list) -> str:
    try:
        _configure()
        model = genai.GenerativeModel(_MODEL_NAME)

        conversation = _CHAT_SYSTEM.format(title=title, transcript=transcript) + "\n"
        for msg in history:
            role = msg.get("role", "user")
            content = msg.get("content", "")
            conversation += f"\n{role}: {content}"
        conversation += f"\nuser: {message}\nassistant:"

        response = model.generate_content(conversation)
        return response.text
    except AIServiceError:
        raise
    except Exception as e:
        raise AIServiceError(f"AI service error: {e}")
