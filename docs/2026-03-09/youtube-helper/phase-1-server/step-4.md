# Phase 1 Step 4: Gemini 서비스

## TC
- TC-1: summarize_transcript가 JSON 파싱 후 올바른 구조 반환
- TC-2: chat_with_transcript가 응답 텍스트 반환
- TC-3: GEMINI_API_KEY 미설정 시 RuntimeError

## 구현
- services/summarizer.py: Gemini로 자막 요약 (JSON 출력 파싱)
- services/chat.py: Gemini로 자막 기반 채팅
- 두 서비스 모두 GEMINI_API_KEY 환경변수 사용

## 결과
- ✅ TC-1: summarizer 구현 완료 (코드펜스 제거 + JSON 파싱)
- ✅ TC-2: chat 구현 완료 (대화 히스토리 포함)
- ✅ TC-3: API 키 없으면 RuntimeError 발생
