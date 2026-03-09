"""API endpoint tests using FastAPI TestClient."""

import sys
sys.path.insert(0, ".")

from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from server.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@patch("server.routers.transcript.get_transcript")
@patch("server.routers.transcript.get_video_metadata")
def test_transcript_endpoint(mock_metadata, mock_transcript):
    mock_metadata.return_value = {
        "video_id": "abc123defgh",
        "title": "Test Video",
        "thumbnail_url": "https://img.youtube.com/vi/abc123defgh/hqdefault.jpg",
    }
    mock_transcript.return_value = [
        {"text": "Hello world", "start": 0.0, "duration": 1.0}
    ]

    response = client.post(
        "/api/v1/transcript",
        json={"url": "https://www.youtube.com/watch?v=abc123defgh"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["metadata"]["video_id"] == "abc123defgh"
    assert data["metadata"]["title"] == "Test Video"
    assert data["metadata"]["thumbnail_url"] != ""
    assert len(data["transcript"]) == 1
    assert data["full_text"] == "Hello world"


@patch("server.routers.summarize.summarize_transcript")
@patch("server.routers.summarize.get_video_metadata")
def test_summarize_endpoint(mock_metadata, mock_summarize):
    mock_metadata.return_value = {
        "video_id": "abc123defgh",
        "title": "Test Video",
        "thumbnail_url": "https://img.youtube.com/vi/abc123defgh/hqdefault.jpg",
    }
    mock_summarize.return_value = {
        "summary": "Test summary",
        "key_points": ["point 1"],
        "chapters": [{"title": "Ch1", "summary": "s", "start_time": "0:00"}],
    }

    response = client.post(
        "/api/v1/summarize",
        json={
            "url": "https://www.youtube.com/watch?v=abc123defgh",
            "transcript": "Hello world transcript",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["summary"] == "Test summary"
    assert len(data["key_points"]) == 1
    assert data["metadata"]["thumbnail_url"] != ""


@patch("server.routers.chat.chat_with_transcript")
def test_chat_endpoint(mock_chat):
    mock_chat.return_value = "This is the answer"

    response = client.post(
        "/api/v1/chat",
        json={
            "transcript": "Hello world transcript",
            "question": "What is this about?",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["answer"] == "This is the answer"


def test_transcript_invalid_url():
    response = client.post(
        "/api/v1/transcript",
        json={"url": "not-a-youtube-url"},
    )
    assert response.status_code == 400
