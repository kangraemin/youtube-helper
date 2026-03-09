import os

import google.generativeai as genai


def _get_model():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable is not set")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel("gemini-2.0-flash")


def summarize_transcript(title: str, transcript: str) -> dict:
    model = _get_model()

    prompt = f"""다음 YouTube 동영상의 자막을 분석하여 요약해주세요.

제목: {title}

자막:
{transcript}

다음 형식으로 응답해주세요:
1. **요약**: 동영상 내용을 3-5문장으로 요약
2. **핵심 포인트**: 3-5개의 핵심 포인트를 bullet point로 정리

요약:"""

    response = model.generate_content(prompt)
    text = response.text

    lines = text.strip().split('\n')
    summary_lines = []
    key_points = []
    in_key_points = False

    for line in lines:
        line = line.strip()
        if not line:
            continue
        if '핵심 포인트' in line or 'key point' in line.lower():
            in_key_points = True
            continue
        if in_key_points:
            cleaned = line.lstrip('- •*').strip()
            if cleaned:
                key_points.append(cleaned)
        else:
            if line.startswith('요약:') or line.startswith('**요약**'):
                line = line.replace('요약:', '').replace('**요약**:', '').replace('**요약**', '').strip()
                if line:
                    summary_lines.append(line)
            else:
                summary_lines.append(line)

    summary = ' '.join(summary_lines) if summary_lines else text
    if not key_points:
        key_points = [summary]

    preview = transcript[:200] + "..." if len(transcript) > 200 else transcript

    return {
        "summary": summary,
        "key_points": key_points,
        "transcript_preview": preview,
    }


def chat_with_transcript(transcript: str, question: str, chat_history: list[dict]) -> str:
    model = _get_model()

    history_text = ""
    for msg in chat_history:
        role = "사용자" if msg["role"] == "user" else "어시스턴트"
        history_text += f"{role}: {msg['content']}\n"

    prompt = f"""다음은 YouTube 동영상의 자막입니다. 이 자막 내용을 기반으로 사용자의 질문에 답변해주세요.

자막:
{transcript}

{f"이전 대화:{chr(10)}{history_text}" if history_text else ""}
사용자 질문: {question}

답변:"""

    response = model.generate_content(prompt)
    return response.text.strip()
