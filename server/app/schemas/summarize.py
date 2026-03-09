from pydantic import BaseModel


class SummarizeRequest(BaseModel):
    url: str


class SummarizeResponse(BaseModel):
    video_id: str
    title: str
    thumbnail_url: str
    summary: str
    key_points: list[str]
    tips: list[str]
