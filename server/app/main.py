from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1.router import router as v1_router
from app.config import settings
from app.utils.exceptions import (
    AIServiceError,
    InvalidYouTubeURL,
    TranscriptNotAvailable,
    VideoNotFound,
)

app = FastAPI(title="YouTube Helper API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(v1_router, prefix="/api/v1")


@app.exception_handler(InvalidYouTubeURL)
async def invalid_url_handler(request: Request, exc: InvalidYouTubeURL):
    return JSONResponse(status_code=400, content={"detail": str(exc)})


@app.exception_handler(VideoNotFound)
async def video_not_found_handler(request: Request, exc: VideoNotFound):
    return JSONResponse(status_code=404, content={"detail": str(exc)})


@app.exception_handler(TranscriptNotAvailable)
async def transcript_not_available_handler(
    request: Request, exc: TranscriptNotAvailable
):
    return JSONResponse(status_code=404, content={"detail": str(exc)})


@app.exception_handler(AIServiceError)
async def ai_service_error_handler(request: Request, exc: AIServiceError):
    return JSONResponse(status_code=502, content={"detail": str(exc)})
