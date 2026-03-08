# Step 2: 히스토리 화면

## 목표
- 이전 요약 기록 목록 표시

## 구현 항목
- 최근 요약 리스트 (썸네일 + 타이틀 + 날짜 + 요약 미리보기)
- 로컬 저장 (SharedPreferences)
- 빈 상태: "아직 요약한 영상이 없어요"
- 항목 탭 → 상세 화면 이동

## 테스트 기준 (QA 작성)
| TC | 설명 | 상태 |
|----|------|------|
| TC-1 | history_screen.dart에 빈 상태 UI 존재 | ✅ PASS |
| TC-2 | ListView.builder로 히스토리 목록 렌더링 | ✅ PASS |
| TC-3 | 각 항목에 thumbnailImageUrl + title + createdAt 표시 | ✅ PASS |
| TC-4 | storage_service.dart에 saveSummary + getHistory 메서드 존재 | ✅ PASS |

## 완료 기준
- 저장된 데이터 리스트 표시
- 빈 상태 UI
