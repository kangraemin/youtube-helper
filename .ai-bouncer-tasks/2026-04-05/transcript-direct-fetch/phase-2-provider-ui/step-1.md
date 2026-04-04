# Step 1: summary_provider.dart + 파일 정리

## TC

| TC | 검증 항목 | 기대 결과 | 상태 |
|----|----------|----------|------|
| TC-01 | flutter analyze | ApiService/chat 관련 에러 없음 | ✅ |

## 실행출력

TC-01: flutter analyze
→ summary_provider.dart 자체 에러 없음 확인
→ UI 파일(home, detail, settings)의 삭제된 메서드 참조 에러는 Step 2/3 대상
