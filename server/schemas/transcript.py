from pydantic import BaseModel


class TranscriptRequest(BaseModel):
    url: str


class TranscriptSegment(BaseModel):
    text: str
    start: float
    duration: float


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    thumbnail_url: str
    transcript: list[TranscriptSegment]
    full_text: str
    language: str
