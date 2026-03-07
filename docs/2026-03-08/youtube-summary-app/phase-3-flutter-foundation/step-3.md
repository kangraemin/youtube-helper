# Step 3: 홈 화면 + 위젯 + Bottom Nav

## 완료 기준
- HomeScreen: URL 입력 + 붙여넣기 버튼 + 요약하기 버튼
- LoadingProgress 위젯: 프로그레스 바 + "AI 요약 중..."
- VideoResultCard 위젯: 썸네일 + 제목 + 요약 스니펫
- Bottom Navigation Bar (홈/기록/설정)
- flutter analyze 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | flutter analyze | 에러 없음 | ✅ PASS |
| TC-2 | 앱 빌드 | 컴파일 성공 | ✅ PASS |

## 구현 내용
- home_screen.dart: URL TextField + content_paste button + 요약하기 FilledButton + error card + result card
- loading_progress.dart: CircularProgressIndicator + "AI 요약 중..." + percent + LinearProgressIndicator
- video_result_card.dart: Image.network thumbnail + title + summary snippet + 전문보기/복사 buttons
- summary_detail_screen.dart: TabBar(요약/스크립트), MarkdownBody summary, inline transcript view, inline chat bubbles, copy FAB
- shell_scaffold.dart: NavigationBar (홈/기록/설정) with GoRouter integration

## 변경 파일
- `app/lib/features/summarize/presentation/home_screen.dart`
- `app/lib/features/summarize/presentation/summary_detail_screen.dart`
- `app/lib/features/summarize/presentation/widgets/loading_progress.dart`
- `app/lib/features/summarize/presentation/widgets/video_result_card.dart`

## 빌드
명령: flutter analyze
결과: No issues found!
