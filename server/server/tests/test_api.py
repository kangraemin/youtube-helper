from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from server.main import app
from server.services.youtube import extract_video_id, get_thumbnail_url


# --- URL 파싱 테스트 ---


class TestExtractVideoId:
    def test_watch_url(self):
        assert extract_video_id("https://www.youtube.com/watch?v=dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_short_url(self):
        assert extract_video_id("https://youtu.be/dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_embed_url(self):
        assert extract_video_id("https://www.youtube.com/embed/dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_shorts_url(self):
        assert extract_video_id("https://www.youtube.com/shorts/dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_mobile_url(self):
        assert extract_video_id("https://m.youtube.com/watch?v=dQw4w9WgXcQ") == "dQw4w9WgXcQ"

    def test_invalid_url(self):
        with pytest.raises(ValueError):
            extract_video_id("https://example.com/video")

    def test_empty_url(self):
        with pytest.raises(ValueError):
            extract_video_id("")


class TestGetThumbnailUrl:
    def test_thumbnail(self):
        url = get_thumbnail_url("dQw4w9WgXcQ")
        assert url == "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"


# --- API 엔드포인트 테스트 ---


@pytest.fixture
def transport():
    return ASGITransport(app=app)


@pytest.mark.asyncio
async def test_health(transport):
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/health")
        assert resp.status_code == 200
        assert resp.json() == {"status": "ok"}


@pytest.mark.asyncio
async def test_transcript_invalid_url(transport):
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post("/api/v1/transcript", json={"url": "not-a-url"})
        assert resp.status_code == 400


@pytest.mark.asyncio
@patch("server.routers.v1.youtube.fetch_transcript")
@patch("server.routers.v1.youtube.fetch_title", new_callable=AsyncMock)
@patch("server.routers.v1.youtube.extract_video_id")
async def test_transcript_success(mock_extract, mock_title, mock_transcript, transport):
    mock_extract.return_value = "abc123"
    mock_title.return_value = "테스트 제목"
    mock_transcript.return_value = "안녕하세요 자막입니다"

    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/api/v1/transcript",
            json={"url": "https://www.youtube.com/watch?v=abc123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "abc123"
        assert data["title"] == "테스트 제목"
        assert data["transcript"] == "안녕하세요 자막입니다"
        assert "thumbnail_url" in data


@pytest.mark.asyncio
@patch("server.routers.v1.ai.summarize_transcript", new_callable=AsyncMock)
async def test_summarize_success(mock_summarize, transport):
    mock_summarize.return_value = {
        "summary": "요약입니다",
        "key_points": ["요점1", "요점2"],
    }

    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/api/v1/summarize",
            json={"video_id": "abc123", "transcript": "자막 텍스트"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["video_id"] == "abc123"
        assert data["summary"] == "요약입니다"
        assert len(data["key_points"]) == 2


@pytest.mark.asyncio
@patch("server.routers.v1.ai.chat_with_transcript", new_callable=AsyncMock)
async def test_chat_success(mock_chat, transport):
    mock_chat.return_value = {
        "answer": "답변입니다",
        "sources": [],
    }

    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/api/v1/chat",
            json={
                "video_id": "abc123",
                "transcript": "자막 텍스트",
                "message": "이 영상 뭐에 대한 거야?",
                "history": [],
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["answer"] == "답변입니다"


@pytest.mark.asyncio
@patch("server.routers.v1.ai.summarize_transcript", new_callable=AsyncMock)
async def test_summarize_api_error(mock_summarize, transport):
    mock_summarize.side_effect = RuntimeError("GEMINI_API_KEY 환경변수가 설정되지 않았습니다.")

    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/api/v1/summarize",
            json={"video_id": "abc123", "transcript": "자막"},
        )
        assert resp.status_code == 500
