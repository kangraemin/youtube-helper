from pydantic import BaseModel


class SummarizeRequest(BaseModel):
    video_id: str
    title: str
    transcript_text: str


class Section(BaseModel):
    title: str
    content: str


class SummarizeResponse(BaseModel):
    video_id: str
    summary: str
    key_points: list[str]
    sections: list[Section]
