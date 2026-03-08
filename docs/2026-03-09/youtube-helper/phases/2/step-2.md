# Step 2: AI 채팅 API 구현

## 목표
- POST /api/v1/chat 엔드포인트 구현

## 구현 항목
- 자막 컨텍스트 기반 질문 응답
- 대화 히스토리 지원 (messages[] 파라미터)
- 응답 스키마: { answer, sources[] }
- Gemini API 연동

## 완료 기준
- 자막 + 질문 → 답변 반환
- 대화 히스토리 유지 확인
