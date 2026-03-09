# Phase 2, Step 3: API 서비스 클래스

## TC

### TC-1: API 서비스 파일 존재
- 입력: 서비스 파일 확인
- 기대결과: api_service.dart, storage_service.dart 존재
- 검증명령: `ls app/lib/services/`
- 결과: ✅ (Step 2에서 함께 구현)

## 구현 내용
- api_service.dart: getTranscript, summarize, chat 메서드
- storage_service.dart: SharedPreferences 기반 히스토리 저장/조회
