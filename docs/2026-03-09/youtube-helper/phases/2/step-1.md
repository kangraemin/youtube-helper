# Step 1: AI 요약 API 구현

## 목표
- POST /api/v1/summarize 엔드포인트 구현

## 구현 항목
- Gemini API 연동 (google-generativeai)
- 자막 텍스트 → 구조화된 요약 생성
- 응답 스키마: { summary, key_points[] }
- 에러 핸들링 (빈 자막, API 오류)

## 완료 기준
- 자막 텍스트 전달 → 요약 + 핵심 요점 반환
- Gemini API 모킹 테스트 통과
