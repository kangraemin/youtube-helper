# Phase 1, Step 4: /api/v1/chat 엔드포인트

## TC

### TC-1: chat 라우트 등록
- 입력: FastAPI 앱 라우트
- 기대결과: /api/v1/chat POST 존재
- 검증명령: `python3 -c "import sys; sys.path.insert(0,'.'); from server.main import app; routes=[r.path for r in app.routes]; assert '/api/v1/chat' in routes; print('OK')"`
- 결과:

### TC-2: 서버 테스트 파일 존재
- 입력: 테스트 파일 확인
- 기대결과: server/tests/test_api.py 존재
- 검증명령: `ls server/tests/test_api.py`
- 결과:

## 구현 내용
(개발 후 기록)
