from pydantic import BaseModel


class TranscriptRequest(BaseModel):
    url: str


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    thumbnail: str
    transcript: str
    duration: str = ""


class SummarizeRequest(BaseModel):
    video_id: str
    transcript: str
    title: str


class SummarizeResponse(BaseModel):
    summary: str
    key_points: list[str]


class ChatRequest(BaseModel):
    video_id: str
    transcript: str
    question: str
    history: list[dict] = []


class ChatResponse(BaseModel):
    answer: str
