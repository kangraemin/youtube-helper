from pydantic import BaseModel


class TranscriptRequest(BaseModel):
    url: str


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    thumbnail_url: str
    duration: str
    transcript: str
    language: str


class SummarizeRequest(BaseModel):
    video_id: str
    transcript: str
    title: str


class SummarizeResponse(BaseModel):
    summary: str
    key_points: list[str]
    transcript_preview: str


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    video_id: str
    transcript: str
    question: str
    chat_history: list[ChatMessage] = []


class ChatResponse(BaseModel):
    answer: str
