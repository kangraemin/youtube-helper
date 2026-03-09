import json
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.schemas.transcript import TranscriptSegment, VideoMeta


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def mock_extract_video_id():
    with patch("app.api.v1.transcript.extract_video_id", return_value="dQw4w9WgXcQ") as m, \
         patch("app.api.v1.summarize.extract_video_id", return_value="dQw4w9WgXcQ"), \
         patch("app.api.v1.chat.extract_video_id", return_value="dQw4w9WgXcQ"):
        yield m


@pytest.fixture
def sample_segments():
    return [
        TranscriptSegment(text="Hello world", start=0.0, duration=2.0),
        TranscriptSegment(text="This is a test", start=2.0, duration=1.5),
    ]


@pytest.fixture
def sample_meta():
    return VideoMeta(
        video_id="dQw4w9WgXcQ",
        title="Test Video",
        thumbnail_url="https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    )


@pytest.fixture
def mock_youtube_service(sample_segments, sample_meta):
    with patch("app.api.v1.transcript.fetch_transcript") as mock_transcript, \
         patch("app.api.v1.transcript.fetch_metadata") as mock_meta, \
         patch("app.api.v1.summarize.fetch_transcript") as mock_transcript2, \
         patch("app.api.v1.summarize.fetch_metadata") as mock_meta2, \
         patch("app.api.v1.chat.fetch_transcript") as mock_transcript3, \
         patch("app.api.v1.chat.fetch_metadata") as mock_meta3:
        for mt in [mock_transcript, mock_transcript2, mock_transcript3]:
            mt.return_value = (sample_segments, "Hello world This is a test", "ko")
        for mm in [mock_meta, mock_meta2, mock_meta3]:
            mm.return_value = sample_meta
        yield {"fetch_transcript": mock_transcript, "fetch_metadata": mock_meta}


@pytest.fixture
def sample_summary():
    return {
        "summary": "This is a summary.",
        "key_points": ["point 1", "point 2", "point 3", "point 4", "point 5"],
        "tips": ["tip 1", "tip 2", "tip 3"],
    }
