# Step 3: Settings 화면 + 네비게이션 완성

## 완료 기준
- SettingsScreen: 다크모드 토글, 서버 URL 입력, 히스토리 삭제 + 확인 대화상자, 앱 버전
- GoRouter 경로 연결 완성
- Bottom Nav active 상태 동작
- flutter analyze 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | flutter analyze | 에러 없음 | ✅ PASS |

## 구현 내용
- settings_screen.dart: 다크모드 SwitchListTile, 서버 URL ListTile + AlertDialog, 히스토리 삭제 + 확인 dialog, 앱 버전 1.0.0
- app_router.dart: HistoryScreen + SettingsScreen imports, real routes wired up
- shell_scaffold.dart: NavigationBar with GoRouter location-based selectedIndex
- DarkModeNotifier persisted to Hive 'settings' box
- ServerUrlNotifier persisted to Hive 'settings' box

## 변경 파일
- `app/lib/features/settings/presentation/settings_screen.dart`
- `app/lib/routing/app_router.dart`

## 빌드
명령: flutter analyze
결과: No issues found!
