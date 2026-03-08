# Step 1: Summarize API

## 완료 기준
- POST /api/v1/summarize 엔드포인트 동작
- Gemini API로 자막 요약 + 핵심 요점 반환

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | summarize 성공 (mock) | 200 + video_id, summary, key_points | ✅ PASS |
| TC-2 | Gemini API 키 미설정 | 500 에러 | ✅ PASS |

## 구현 내용
- server/services/ai.py: summarize_transcript() — Gemini 2.0 Flash로 JSON 형식 요약
- server/routers/v1.py: POST /api/v1/summarize 엔드포인트
- pytest test_summarize_success, test_summarize_api_error 통과
