import os

import google.generativeai as genai


def chat_with_transcript(transcript: str, question: str, history: list) -> str:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY environment variable is not set")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-pro")

    system_context = (
        "당신은 유튜브 영상 내용에 대해 답변하는 AI 어시스턴트입니다.\n"
        f"다음은 영상의 자막 내용입니다:\n\n{transcript}\n\n"
        "위 자막 내용을 바탕으로 사용자의 질문에 답변해주세요."
    )

    chat_history = []
    for entry in history:
        role = entry.get("role", "user")
        parts = entry.get("parts", [entry.get("content", "")])
        if isinstance(parts, str):
            parts = [parts]
        chat_history.append({"role": role, "parts": parts})

    try:
        chat = model.start_chat(history=chat_history)
        full_prompt = f"{system_context}\n\n질문: {question}"
        response = chat.send_message(full_prompt)
        return response.text.strip()
    except Exception as e:
        raise RuntimeError(f"Failed to chat: {e}")
