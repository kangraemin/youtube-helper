# Phase 1 Step 2: YouTube 서비스

## TC
- TC-1: extract_video_id로 다양한 URL 파싱 성공
- TC-2: get_video_metadata가 title, thumbnail_url 반환
- TC-3: get_transcript가 자막 텍스트 반환

## 구현
- services/youtube.py
- extract_video_id: youtube.com/watch, youtu.be, shorts, embed 지원
- get_video_metadata: oEmbed API로 타이틀 + 썸네일
- get_transcript: youtube-transcript-api로 자막 추출
- fetch_transcript_with_metadata: 통합 함수

## 결과
- ✅ TC-1: 5개 URL 패턴 테스트 통과
- ✅ TC-2: 구현 완료 (oEmbed + maxresdefault 썸네일)
- ✅ TC-3: 구현 완료 (수동/자동 자막 우선순위)
