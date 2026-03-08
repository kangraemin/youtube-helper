import os

from server.models.schemas import SummarizeResponse, ChatResponse, ChatMessage

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")


async def summarize_transcript(video_id: str, transcript: str) -> SummarizeResponse:
    """Summarize transcript using Gemini API."""
    if not transcript.strip():
        raise ValueError("Transcript is empty")

    try:
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel("gemini-pro")

        prompt = f"""다음 YouTube 영상 자막을 한국어로 요약해주세요.

자막:
{transcript}

다음 형식으로 응답해주세요:
요약: (3-5문장 요약)
핵심 요점:
- 요점 1
- 요점 2
- 요점 3"""

        response = model.generate_content(prompt)
        text = response.text

        lines = text.strip().split("\n")
        summary = ""
        key_points = []
        in_points = False

        for line in lines:
            line = line.strip()
            if line.startswith("요약:"):
                summary = line[len("요약:"):].strip()
            elif line.startswith("핵심 요점:"):
                in_points = True
            elif in_points and line.startswith("- "):
                key_points.append(line[2:].strip())
            elif not in_points and summary:
                summary += " " + line

        if not summary:
            summary = text[:500]
        if not key_points:
            key_points = ["요약 생성 완료"]

        return SummarizeResponse(
            video_id=video_id,
            summary=summary,
            key_points=key_points,
        )
    except ImportError:
        return SummarizeResponse(
            video_id=video_id,
            summary="Gemini API not available",
            key_points=["Install google-generativeai package"],
        )


async def chat_with_transcript(
    video_id: str, transcript: str, message: str, history: list[ChatMessage]
) -> ChatResponse:
    """Chat about transcript using Gemini API."""
    if not transcript.strip():
        raise ValueError("Transcript is empty")

    try:
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel("gemini-pro")

        history_text = ""
        for msg in history:
            history_text += f"{msg.role}: {msg.content}\n"

        prompt = f"""다음 YouTube 영상 자막을 기반으로 질문에 답변해주세요.

자막:
{transcript}

대화 기록:
{history_text}

질문: {message}

답변할 때 자막에서 관련 부분을 인용해주세요."""

        response = model.generate_content(prompt)
        answer = response.text

        sources = []
        words = transcript.split()
        if len(words) > 10:
            for i in range(0, min(len(words), 30), 10):
                sources.append(" ".join(words[i:i+10]))

        return ChatResponse(answer=answer, sources=sources)
    except ImportError:
        return ChatResponse(
            answer="Gemini API not available",
            sources=[],
        )
