# Phase 1: Backend Foundation

## 개발 범위
- FastAPI 앱 생성 (main.py, CORS, uvicorn)
- Pydantic 모델 정의 (schemas.py)
- YouTube 트랜스크립트 서비스 (transcript_service.py)
- API 라우터 (api_v1.py - POST /transcript)
- requirements.txt 생성
- 테스트 (conftest.py, test_transcript.py)

## Step 목록
- Step 1: Models + Transcript Service + Requirements — schemas.py, transcript_service.py, requirements.txt 생성
- Step 2: Router + Main + Tests — api_v1.py, main.py, conftest.py, test_transcript.py 생성 및 테스트 통과

## 이 Phase 완료 기준
- pytest tests/test_transcript.py -v 통과
