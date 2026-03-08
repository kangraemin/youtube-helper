# Step 2: 자막 추출 API 구현

## 목표
- POST /api/v1/transcript 엔드포인트 구현

## 구현 항목
- YouTube URL 파싱 및 유효성 검증
- youtube-transcript-api로 자막 추출
- 영상 메타데이터 추출 (제목, 썸네일 URL, 길이)
- 응답 스키마: { video_id, title, thumbnail_url, transcript, duration }

## 완료 기준
- 유효한 URL → 자막 + 메타데이터 반환
- 잘못된 URL → 422 에러
- 자막 없는 영상 → 적절한 에러 메시지
