import os

import google.generativeai as genai


def summarize_transcript(transcript: str, title: str) -> dict:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY environment variable is not set")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-pro")

    prompt = (
        f"다음은 '{title}'이라는 유튜브 영상의 자막입니다.\n\n"
        f"{transcript}\n\n"
        "위 내용을 요약하고, 핵심 포인트 3~5개를 정리해주세요.\n"
        "반드시 아래 JSON 형식으로만 응답하세요:\n"
        '{"summary": "요약 내용", "key_points": ["포인트1", "포인트2", "포인트3"]}'
    )

    try:
        response = model.generate_content(prompt)
        text = response.text.strip()
        # Parse JSON from response
        import json

        # Try to extract JSON from response text
        start = text.find("{")
        end = text.rfind("}") + 1
        if start >= 0 and end > start:
            data = json.loads(text[start:end])
            return {
                "summary": data.get("summary", ""),
                "key_points": data.get("key_points", []),
            }
        return {"summary": text, "key_points": []}
    except Exception as e:
        raise RuntimeError(f"Failed to summarize transcript: {e}")
