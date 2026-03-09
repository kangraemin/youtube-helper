import os
import json
import asyncio

import google.generativeai as genai


def _get_model():
    api_key = os.environ.get("GEMINI_API_KEY", "")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel("gemini-2.0-flash")


async def generate_summary(title: str, full_text: str, language: str = "ko") -> dict:
    """Generate a structured summary using Gemini."""
    model = _get_model()

    prompt = f"""You are a YouTube video summarizer. Summarize the following video transcript.
Respond in {"Korean" if language == "ko" else "English"}.

Title: {title}
Transcript: {full_text}

Respond in JSON format with these fields:
- "summary": A concise 2-3 sentence summary
- "key_points": A list of 3-5 key points as strings
- "full_summary": A detailed paragraph summary

Return ONLY valid JSON, no markdown code blocks."""

    def _call():
        response = model.generate_content(
            prompt,
            generation_config=genai.GenerationConfig(
                response_mime_type="application/json",
            ),
        )
        return json.loads(response.text)

    return await asyncio.to_thread(_call)


async def chat_with_context(full_text: str, messages: list[dict]) -> str:
    """Chat about a video transcript using Gemini."""
    model = _get_model()

    system_prompt = f"""You are a helpful assistant that answers questions about a YouTube video.
Here is the video transcript:

{full_text}

Answer the user's questions based on the transcript content."""

    chat_history = []
    for msg in messages[:-1]:
        role = "user" if msg["role"] == "user" else "model"
        chat_history.append({"role": role, "parts": [msg["content"]]})

    last_message = messages[-1]["content"]

    def _call():
        chat = model.start_chat(history=[
            {"role": "user", "parts": [system_prompt]},
            {"role": "model", "parts": ["I understand. I'll answer questions based on the video transcript."]},
            *chat_history,
        ])
        response = chat.send_message(last_message)
        return response.text

    return await asyncio.to_thread(_call)
