from fastapi import HTTPException


class InvalidURLError(HTTPException):
    def __init__(self, detail: str = "Invalid YouTube URL"):
        super().__init__(status_code=400, detail=detail)


class VideoNotFoundError(HTTPException):
    def __init__(self, detail: str = "Video not found or is private"):
        super().__init__(status_code=404, detail=detail)


class TranscriptNotFoundError(HTTPException):
    def __init__(self, detail: str = "Transcript not available for this video"):
        super().__init__(status_code=404, detail=detail)


class GeminiError(HTTPException):
    def __init__(self, detail: str = "Gemini API error"):
        super().__init__(status_code=502, detail=detail)
