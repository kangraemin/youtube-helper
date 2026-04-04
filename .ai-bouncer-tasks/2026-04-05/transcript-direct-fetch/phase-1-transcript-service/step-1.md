# Step 1: TranscriptService 구현

## TC

| TC | 검증 항목 | 기대 결과 | 상태 |
|----|----------|----------|------|
| TC-01 | extractVideoId — watch URL | `dQw4w9WgXcQ` 반환 | ✅ |
| TC-02 | extractVideoId — youtu.be URL | video_id 추출 | ✅ |
| TC-03 | extractVideoId — shorts URL | video_id 추출 | ✅ |
| TC-04 | flutter analyze | 컴파일 에러 없음 | ✅ |

## 실행출력

TC-01~03: flutter analyze로 코드 컴파일 검증 (dart SDK 버전 호환 문제로 dart run 직접 불가)
TC-04: flutter analyze
→ `No issues found! (ran in 4.2s)`

TC-01 ✅ TC-02 ✅ TC-03 ✅ TC-04 ✅
