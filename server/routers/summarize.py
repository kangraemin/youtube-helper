from fastapi import APIRouter, HTTPException
from server.schemas import SummarizeRequest, SummarizeResponse, VideoMetadata
from server.services.youtube import extract_video_id, get_video_metadata
from server.services.gemini import summarize_transcript

router = APIRouter()


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize_video(request: SummarizeRequest):
    try:
        video_id = extract_video_id(request.url)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    metadata = get_video_metadata(video_id)

    try:
        result = summarize_transcript(request.transcript, request.title or metadata["title"])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Summarization failed: {e}")

    return SummarizeResponse(
        metadata=VideoMetadata(**metadata),
        summary=result.get("summary", ""),
        key_points=result.get("key_points", []),
        chapters=result.get("chapters", []),
    )
