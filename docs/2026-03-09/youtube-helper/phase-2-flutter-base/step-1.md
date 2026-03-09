# Phase 2, Step 1: Flutter 프로젝트 생성 + 의존성

## TC

### TC-1: Flutter 프로젝트 구조
- 입력: app/ 디렉토리 확인
- 기대결과: app/pubspec.yaml, app/lib/main.dart 존재
- 검증명령: `ls app/pubspec.yaml app/lib/main.dart`
- 결과:

### TC-2: pubspec.yaml 필수 의존성
- 입력: pubspec.yaml 확인
- 기대결과: http, shared_preferences 포함
- 검증명령: `grep -cE 'http:|shared_preferences:' app/pubspec.yaml`
- 결과:

## 구현 내용
(개발 후 기록)
