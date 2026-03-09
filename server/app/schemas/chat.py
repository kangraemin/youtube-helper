from pydantic import BaseModel


class ChatMessage(BaseModel):
    role: str  # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    video_id: str
    transcript_text: str
    messages: list[ChatMessage]


class ChatResponse(BaseModel):
    reply: str
