# Step 2: Chat API

## 완료 기준
- POST /api/v1/chat 엔드포인트 동작
- 자막 기반 Q&A + 대화 히스토리 지원

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | chat 성공 (mock) | 200 + answer, sources | ✅ PASS |

## 구현 내용
- server/services/ai.py: chat_with_transcript() — 자막 컨텍스트 + 히스토리 기반 Q&A
- server/routers/v1.py: POST /api/v1/chat 엔드포인트
- pytest test_chat_success 통과
