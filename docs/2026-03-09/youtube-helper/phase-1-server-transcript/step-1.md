# Step 1: FastAPI 프로젝트 구조 + 의존성

## 완료 기준
- server/ 디렉토리에 FastAPI 프로젝트 구조 생성
- requirements.txt, main.py, 라우터, 서비스, 모델 파일 존재

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | FastAPI 앱 import | app 객체 import 성공 | ✅ PASS |
| TC-2 | requirements.txt 존재 | fastapi, uvicorn 등 의존성 포함 | ✅ PASS |
| TC-3 | API 라우터 등록 | /api/v1 prefix 라우터 존재 | ✅ PASS |

## 구현 내용
- server/ 디렉토리 구조: main.py, routers/v1.py, services/{youtube,ai}.py, models/schemas.py
- requirements.txt: fastapi, uvicorn, youtube-transcript-api, google-generativeai, httpx, pytest, pytest-asyncio
- CORS 미들웨어 설정, /health 엔드포인트
- pytest 14 tests passed
