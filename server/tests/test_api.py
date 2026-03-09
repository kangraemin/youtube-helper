import sys
import os
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from main import app

client = TestClient(app)


def test_health():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@patch("routers.api_v1.extract_transcript")
def test_transcript(mock_extract):
    mock_extract.return_value = {
        "video_id": "abc123",
        "title": "Test Video",
        "thumbnail": "https://img.youtube.com/vi/abc123/hqdefault.jpg",
        "transcript": "Hello world",
        "duration": "",
    }
    response = client.post(
        "/api/v1/transcript",
        json={"url": "https://www.youtube.com/watch?v=abc123"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["video_id"] == "abc123"
    assert data["title"] == "Test Video"
    assert data["transcript"] == "Hello world"
    assert "thumbnail" in data
    assert "duration" in data


@patch("routers.api_v1.summarize_transcript")
def test_summarize(mock_summarize):
    mock_summarize.return_value = {
        "summary": "This is a summary",
        "key_points": ["point 1", "point 2", "point 3"],
    }
    response = client.post(
        "/api/v1/summarize",
        json={
            "video_id": "abc123",
            "transcript": "Hello world transcript",
            "title": "Test Video",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["summary"] == "This is a summary"
    assert len(data["key_points"]) == 3


@patch("routers.api_v1.chat_with_transcript")
def test_chat(mock_chat):
    mock_chat.return_value = "This is the answer"
    response = client.post(
        "/api/v1/chat",
        json={
            "video_id": "abc123",
            "transcript": "Hello world transcript",
            "question": "What is this about?",
            "history": [],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["answer"] == "This is the answer"
