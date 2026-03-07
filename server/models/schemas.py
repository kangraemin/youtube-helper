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
    transcript: list[TranscriptSegment]
    full_text: str


class SummarizeRequest(BaseModel):
    video_id: str
    title: str
    full_text: str
    language: str = "ko"


class SummarizeResponse(BaseModel):
    video_id: str
    summary: str


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    video_id: str
    title: str
    full_text: str
    messages: list[ChatMessage]
    language: str = "ko"


class ChatResponse(BaseModel):
    video_id: str
    reply: str


class ErrorResponse(BaseModel):
    detail: str
