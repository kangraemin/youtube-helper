# Step 1: Gemini Service + Summarize/Chat Endpoints + Tests

## 완료 기준
- server/services/gemini_service.py: summarize_transcript(), chat_about_video() 구현
- server/routers/api_v1.py: POST /summarize, POST /chat 추가
- server/tests/test_summarize.py: mock 기반 테스트 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | POST /api/v1/summarize (mocked Gemini) | 200 + SummarizeResponse | ✅ PASS |
| TC-2 | POST /api/v1/chat (mocked Gemini) | 200 + ChatResponse | ✅ PASS |
| TC-3 | 전체 테스트 스위트 통과 | All passed | ✅ 15/15 PASS |

## 구현 내용
- `server/services/gemini_service.py`: lazy client init, summarize_transcript (structured summary), chat_about_video (multi-turn)
- `server/routers/api_v1.py`: POST /summarize, POST /chat 엔드포인트 추가
- `server/tests/test_summarize.py`: mock 기반 5개 테스트 (summarize 성공/실패, chat 성공/실패/멀티턴)

## 빌드
- 명령어: `./venv/bin/python -m pytest tests/ -v`
- 결과: 15/15 통과
