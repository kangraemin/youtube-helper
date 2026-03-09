from fastapi import APIRouter, HTTPException
from server.schemas import TranscriptRequest, TranscriptResponse, VideoMetadata, TranscriptSegment
from server.services.youtube import extract_video_id, get_video_metadata, get_transcript

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
async def get_video_transcript(request: TranscriptRequest):
    try:
        video_id = extract_video_id(request.url)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    try:
        metadata = get_video_metadata(video_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get video metadata: {e}")

    try:
        segments = get_transcript(video_id)
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Transcript not available: {e}")

    full_text = " ".join(seg["text"] for seg in segments)

    return TranscriptResponse(
        metadata=VideoMetadata(**metadata),
        transcript=[TranscriptSegment(**seg) for seg in segments],
        full_text=full_text,
    )
