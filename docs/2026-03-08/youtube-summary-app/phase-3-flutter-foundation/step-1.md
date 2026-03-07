# Step 1: 프로젝트 생성 + 기반 구조

## 완료 기준
- flutter create 성공
- pubspec.yaml 의존성 추가 + flutter pub get 성공
- main.dart (Hive init + ProviderScope)
- app.dart (MaterialApp.router + theme)
- app_theme.dart (YouTube Red Material 3 light/dark)
- app_router.dart (GoRouter: /, /summary, /history, /settings)
- flutter analyze 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | flutter pub get | 의존성 설치 성공 | ✅ PASS |
| TC-2 | flutter analyze | 에러 없음 | ✅ PASS |

## 구현 내용
- flutter create app --org com.youtubehelper
- pubspec.yaml: flutter_riverpod, go_router, freezed_annotation, json_annotation, hive_flutter, http, flutter_markdown, google_fonts + dev deps
- main.dart: Hive init (settings, history boxes) + ProviderScope
- app.dart: MaterialApp.router + light/dark theme + debugShowCheckedModeBanner: false
- app_theme.dart: YouTube Red (#FF0000) Material 3, light bg #F8F5F5, dark bg #230F0F, Work Sans font
- app_router.dart: GoRouter with ShellRoute (/, /history, /settings) + /summary/:videoId
- shell_scaffold.dart: NavigationBar with 3 destinations (홈/기록/설정)
- api_constants.dart: server URL + endpoints

## 변경 파일
- `app/pubspec.yaml`
- `app/lib/main.dart`
- `app/lib/app.dart`
- `app/lib/core/theme/app_theme.dart`
- `app/lib/core/constants/api_constants.dart`
- `app/lib/routing/app_router.dart`
- `app/lib/routing/shell_scaffold.dart`

## 빌드
명령: flutter analyze
결과: No issues found!
