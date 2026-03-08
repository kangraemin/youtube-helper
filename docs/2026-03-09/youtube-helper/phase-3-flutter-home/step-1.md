# Step 1: Flutter 프로젝트 생성 + 네비게이션

## 목표
- app/ 디렉토리에 Flutter 프로젝트 구조 생성

## 구현 항목
- Flutter 프로젝트 생성
- 하단 네비게이션 (홈, 히스토리, 설정)
- 라우팅 구조
- HTTP 클라이언트 서비스
- 상태 관리 (Provider)

## 테스트 기준 (QA 작성)
| TC | 설명 | 상태 |
|----|------|------|
| TC-1 | pubspec.yaml에 http, provider, shared_preferences, cached_network_image 의존성 포함 | ✅ PASS |
| TC-2 | main.dart에 BottomNavigationBar 위젯 존재 | ✅ PASS |
| TC-3 | 3개 탭 존재 (홈, 히스토리, 설정) | ✅ PASS |
| TC-4 | 빨간색 테마 적용 (ColorScheme red 계열) | ✅ PASS |

## 완료 기준
- 앱 빌드 성공
- 하단 네비게이션 탭 전환 동작
