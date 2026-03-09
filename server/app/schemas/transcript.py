from pydantic import BaseModel


class TranscriptRequest(BaseModel):
    url: str


class Segment(BaseModel):
    start: float
    duration: float
    text: str


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    thumbnail_url: str
    duration_seconds: float
    language: str
    segments: list[Segment]
    transcript_text: str
