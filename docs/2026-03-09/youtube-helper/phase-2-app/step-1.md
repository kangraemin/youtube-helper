# Step 1: Flutter 프로젝트 + 의존성

## TC-1: pubspec.yaml 의존성
- 입력: `grep -E "http:|provider:|shared_preferences:" app/pubspec.yaml`
- 기대결과: http, provider, shared_preferences 패키지 포함
- 결과:

## TC-2: 프로젝트 분석 통과
- 입력: `cd app && flutter analyze --no-pub 2>&1 | tail -3`
- 기대결과: No issues found 또는 info만
- 결과:
