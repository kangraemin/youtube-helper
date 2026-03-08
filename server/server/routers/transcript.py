from fastapi import APIRouter, HTTPException

from server.models.schemas import TranscriptRequest, TranscriptResponse
from server.services.transcript_service import extract_transcript

router = APIRouter()


@router.post("/transcript", response_model=TranscriptResponse)
async def get_transcript(request: TranscriptRequest):
    try:
        result = await extract_transcript(request.url)
        return result
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
