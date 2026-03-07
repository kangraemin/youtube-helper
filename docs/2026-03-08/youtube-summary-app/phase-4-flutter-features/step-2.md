# Step 2: History 화면 + Chat Bubble

## 완료 기준
- HistoryScreen: 썸네일(24x16)+타이틀+시간 리스트, 스와이프 삭제, 빈 상태
- ChatBubble 위젯: User(우측, primary) vs Assistant(좌측, surface)
- 채팅 섹션 (SummaryDetail 하단)
- flutter analyze 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | flutter analyze | 에러 없음 | ✅ PASS |

## 구현 내용
- history_screen.dart: AppBar "히스토리", empty state (history_toggle_off + "아직 요약한 영상이 없어요")
- History list: 96x64 thumbnail + bold title (2-line) + relative time ("2시간 전", "어제") + summary snippet
- Swipe-to-delete: red background + delete icon, Dismissible widget
- InkWell onTap: loads summary from history + navigates to /summary/:videoId
- Chat bubbles inline in summary_detail_screen: user=right/primary, assistant=left/surfaceContainerHighest
- "최근 요약 기록" section header

## 변경 파일
- `app/lib/features/history/presentation/history_screen.dart`

## 빌드
명령: flutter analyze
결과: No issues found!
