from pydantic import BaseModel


class TranscriptRequest(BaseModel):
    url: str


class TranscriptResponse(BaseModel):
    video_id: str
    title: str
    thumbnail_url: str
    duration: str
    transcript: str


class SummarizeRequest(BaseModel):
    video_id: str
    transcript: str


class SummarizeResponse(BaseModel):
    video_id: str
    summary: str
    key_points: list[str]
    action_points: list[str]


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    video_id: str
    transcript: str
    message: str
    history: list[ChatMessage] = []


class ChatResponse(BaseModel):
    video_id: str
    reply: str
