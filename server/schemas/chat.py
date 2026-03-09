from pydantic import BaseModel


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    video_id: str
    full_text: str
    messages: list[ChatMessage]


class ChatResponse(BaseModel):
    video_id: str
    reply: str
