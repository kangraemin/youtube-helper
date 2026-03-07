# Step 1: Models + Transcript Service + Requirements

## 완료 기준
- server/models/schemas.py: 모든 Pydantic 모델 정의
- server/services/transcript_service.py: extract_video_id, get_video_title, get_transcript 구현
- server/requirements.txt: pip freeze로 생성
- server/models/__init__.py, server/services/__init__.py 생성

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | extract_video_id("https://www.youtube.com/watch?v=abc123") | "abc123" | ✅ PASS |
| TC-2 | extract_video_id("https://youtu.be/abc123") | "abc123" | ✅ PASS |
| TC-3 | extract_video_id("https://www.youtube.com/shorts/abc123") | "abc123" | ✅ PASS |
| TC-4 | extract_video_id("invalid-url") | ValueError | ✅ PASS |
| TC-5 | TranscriptRequest(url="test") 모델 생성 | 정상 생성 | ✅ PASS |

## 구현 내용
- `server/requirements.txt`: pip freeze로 43개 패키지 버전 고정
- `server/models/__init__.py`: 빈 파일
- `server/models/schemas.py`: 8개 Pydantic 모델 (TranscriptRequest/Segment/Response, SummarizeRequest/Response, ChatMessage, ChatRequest/Response, ErrorResponse)
- `server/services/__init__.py`: 빈 파일
- `server/services/transcript_service.py`: extract_video_id (watch/youtu.be/shorts), get_video_title (oembed), get_transcript (youtube-transcript-api)

## 변경 파일
- `server/requirements.txt`
- `server/models/__init__.py`
- `server/models/schemas.py`
- `server/services/__init__.py`
- `server/services/transcript_service.py`
