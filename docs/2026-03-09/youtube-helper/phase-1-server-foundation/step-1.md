# Step 1: FastAPI 프로젝트 설정 + Pydantic 스키마

## TC
- TranscriptRequest, TranscriptResponse, SummarizeRequest, SummarizeResponse, ChatRequest, ChatResponse 스키마 생성
- FastAPI app 생성 + CORS 설정
- 검증: `cd server && python -c "from schemas.models import *; print('OK')"`

## 구현
- server/main.py
- server/schemas/models.py
- server/requirements.txt

## 결과
✅
