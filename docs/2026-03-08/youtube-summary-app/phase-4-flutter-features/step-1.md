# Step 1: Summary Detail 화면 + Transcript View

## 완료 기준
- SummaryDetailScreen: 썸네일 + TabBar(요약/스크립트) + markdown 요약 + 타임스탬프 스크립트
- TranscriptView 위젯: 빨간 타임스탬프 마커
- Copy FAB (content_copy)
- flutter analyze 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | flutter analyze | 에러 없음 | ✅ PASS |

## 구현 내용
- summary_detail_screen.dart: AppBar(title+back+more), thumbnail, TabBar(요약/스크립트전문)
- 요약 탭: auto_awesome icon + MarkdownBody rendering
- 스크립트 탭: ListView with red timestamps (MM:SS) + segment text
- Copy FAB: content_copy icon, primary background, copies summary to clipboard
- Chat section: inline chat bubbles (user=primary right, assistant=surface left) + text input + send button

## 변경 파일
- `app/lib/features/summarize/presentation/summary_detail_screen.dart`
- `app/lib/routing/app_router.dart` (wired up real screens)

## 빌드
명령: flutter analyze
결과: No issues found!
