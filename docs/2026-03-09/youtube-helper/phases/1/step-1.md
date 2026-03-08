# Step 1: FastAPI 프로젝트 셋업

## 목표
- server/ 디렉토리에 FastAPI 프로젝트 구조 생성

## 구현 항목
- pyproject.toml 또는 requirements.txt 의존성 관리
- main.py: FastAPI app 인스턴스, CORS 미들웨어, 에러 핸들링
- API 라우터 구조 (/api/v1/)
- Gemini API 클라이언트 설정 (config)

## 완료 기준
- `uvicorn server.main:app` 실행 가능
- GET /api/v1/health → 200 OK
