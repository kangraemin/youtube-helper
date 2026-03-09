from fastapi import APIRouter

from app.api.v1.transcript import router as transcript_router
from app.api.v1.summarize import router as summarize_router
from app.api.v1.chat import router as chat_router

router = APIRouter()
router.include_router(transcript_router)
router.include_router(summarize_router)
router.include_router(chat_router)
