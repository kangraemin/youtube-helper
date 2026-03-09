# Phase 1 Step 3: API 엔드포인트

## TC
- TC-1: POST /api/v1/transcript 성공 응답
- TC-2: POST /api/v1/summarize 성공 응답
- TC-3: POST /api/v1/chat 성공 응답
- TC-4: 잘못된 URL에 400 응답

## 구현
- api/v1/endpoints.py: 3개 엔드포인트 (transcript, summarize, chat)
- main.py에 라우터 등록

## 결과
- ✅ TC-1: transcript 엔드포인트 테스트 통과
- ✅ TC-2: summarize 엔드포인트 테스트 통과
- ✅ TC-3: chat 엔드포인트 테스트 통과 (history 포함)
- ✅ TC-4: ValueError → 400, RuntimeError → 500
