# Step 2: API 서비스 + 홈 화면 UI

## 목표
- YouTube URL 입력 → 요약 요청 → 결과 표시

## 구현 항목
- URL 입력 필드 + 붙여넣기 아이콘
- 빨간색 "요약하기" 버튼
- 진행 프로그레스바
- 결과 카드: 썸네일 + 타이틀 + 요약 미리보기
- "전문 보기" → 상세 화면 이동

## 테스트 기준 (QA 작성)
| TC | 설명 | 상태 |
|----|------|------|
| TC-1 | api_service.dart에 getTranscript, summarize, chat 메서드 존재 | ✅ PASS |
| TC-2 | home_screen.dart에 TextField + ElevatedButton 존재 | ✅ PASS |
| TC-3 | 결과 카드에 Image.network + title + summary 표시 | ✅ PASS |
| TC-4 | SummaryProvider에 progress 추적 로직 존재 | ✅ PASS |

## 완료 기준
- URL 입력 → API 호출 → 결과 카드 표시
