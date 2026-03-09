from fastapi import APIRouter, HTTPException

from schemas.summarize import SummarizeRequest, SummarizeResponse
from services.gemini import generate_summary

router = APIRouter()


@router.post("/summarize", response_model=SummarizeResponse)
async def post_summarize(req: SummarizeRequest):
    try:
        result = await generate_summary(req.title, req.full_text, req.language)
    except Exception:
        raise HTTPException(status_code=500, detail="Summarization failed")

    return SummarizeResponse(
        video_id=req.video_id,
        summary=result["summary"],
        key_points=result["key_points"],
        full_summary=result["full_summary"],
    )
