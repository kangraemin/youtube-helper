from pydantic import BaseModel, Field


class TranscriptRequest(BaseModel):
    url: str = Field(..., description="YouTube video URL")


class TranscriptSegment(BaseModel):
    text: str
    start: float
    duration: float


class VideoMetadata(BaseModel):
    video_id: str
    title: str
    thumbnail_url: str


class TranscriptResponse(BaseModel):
    metadata: VideoMetadata
    transcript: list[TranscriptSegment]
    full_text: str


class SummarizeRequest(BaseModel):
    url: str = Field(..., description="YouTube video URL")
    transcript: str = Field(..., description="Full transcript text")
    title: str = Field(default="", description="Video title for context")


class SummaryResult(BaseModel):
    summary: str
    key_points: list[str]
    chapters: list[dict]


class SummarizeResponse(BaseModel):
    metadata: VideoMetadata
    summary: str
    key_points: list[str]
    chapters: list[dict]


class ChatRequest(BaseModel):
    transcript: str = Field(..., description="Full transcript text")
    question: str = Field(..., description="User question")
    history: list[dict] = Field(default_factory=list, description="Chat history")


class ChatResponse(BaseModel):
    answer: str
