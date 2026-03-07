from unittest.mock import patch


def test_summarize_endpoint(client):
    mock_summary = "- 핵심 포인트 1\n- 핵심 포인트 2"
    with patch("routers.api_v1.gemini_service.summarize_transcript", return_value=mock_summary):
        resp = client.post(
            "/api/v1/summarize",
            json={"transcript": "안녕하세요 테스트입니다", "video_title": "테스트 영상"},
        )
    assert resp.status_code == 200
    assert resp.json()["summary"] == mock_summary


def test_chat_endpoint(client):
    mock_reply = "답변입니다."
    with patch("routers.api_v1.gemini_service.chat", return_value=mock_reply):
        resp = client.post(
            "/api/v1/chat",
            json={
                "transcript": "자막 내용",
                "summary": "요약 내용",
                "video_title": "테스트",
                "message": "질문입니다",
                "history": [],
            },
        )
    assert resp.status_code == 200
    assert resp.json()["reply"] == mock_reply
