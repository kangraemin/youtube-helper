from pydantic import BaseModel


class ChatMessage(BaseModel):
    role: str  # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    url: str
    message: str
    history: list[ChatMessage] = []


class ChatResponse(BaseModel):
    video_id: str
    reply: str
    history: list[ChatMessage]
