from pydantic import BaseModel


class SummarizeRequest(BaseModel):
    video_id: str
    title: str
    full_text: str
    language: str = "ko"


class SummarizeResponse(BaseModel):
    video_id: str
    summary: str
    key_points: list[str]
    full_summary: str
