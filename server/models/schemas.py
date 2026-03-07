from pydantic import BaseModel


class TranscriptRequest(BaseModel):
    url: str


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    transcript: str
    thumbnail_url: str
    source: str  # "youtube-transcript-api" or future "whisper"


class SummarizeRequest(BaseModel):
    transcript: str
    video_title: str


class SummarizeResponse(BaseModel):
    summary: str


class ChatMessage(BaseModel):
    role: str  # "user" or "assistant"
    content: str


class ChatRequest(BaseModel):
    transcript: str
    summary: str
    video_title: str
    message: str
    history: list[ChatMessage] = []


class ChatResponse(BaseModel):
    reply: str
