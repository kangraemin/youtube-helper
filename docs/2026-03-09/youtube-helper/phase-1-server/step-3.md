# Phase 1, Step 3: /api/v1/summarize 엔드포인트

## TC

### TC-1: Gemini 서비스 함수 존재
- 입력: gemini.py 임포트
- 기대결과: summarize_transcript, chat_with_transcript 함수 존재
- 검증명령: `python3 -c "import sys; sys.path.insert(0,'.'); from server.services.gemini import summarize_transcript, chat_with_transcript; print('OK')"`
- 결과:

### TC-2: summarize 라우트 등록
- 입력: FastAPI 앱 라우트
- 기대결과: /api/v1/summarize POST 존재
- 검증명령: `python3 -c "import sys; sys.path.insert(0,'.'); from server.main import app; routes=[r.path for r in app.routes]; assert '/api/v1/summarize' in routes; print('OK')"`
- 결과:

## 구현 내용
(개발 후 기록)
