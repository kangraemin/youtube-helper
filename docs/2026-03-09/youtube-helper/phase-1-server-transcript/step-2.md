# Step 2: Transcript API 구현

## 완료 기준
- POST /api/v1/transcript 엔드포인트 동작
- YouTube URL 파싱 (watch, youtu.be, embed, shorts)
- 자막 추출 + 메타데이터 반환

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | watch URL 파싱 | video_id 추출 성공 | ✅ PASS |
| TC-2 | youtu.be URL 파싱 | video_id 추출 성공 | ✅ PASS |
| TC-3 | embed URL 파싱 | video_id 추출 성공 | ✅ PASS |
| TC-4 | shorts URL 파싱 | video_id 추출 성공 | ✅ PASS |
| TC-5 | 잘못된 URL | 400 에러 | ✅ PASS |
| TC-6 | transcript 성공 (mock) | 200 + video_id, title, transcript | ✅ PASS |
| TC-7 | 썸네일 URL 생성 | hqdefault.jpg URL | ✅ PASS |

## 구현 내용
- extract_video_id(): watch, youtu.be, embed, shorts URL 파싱
- fetch_title(): YouTube oEmbed API로 제목 추출
- fetch_transcript(): youtube-transcript-api (한국어 > 영어 > 자동생성)
- get_thumbnail_url(): img.youtube.com 직접 구성
- pytest 14 tests all passed
