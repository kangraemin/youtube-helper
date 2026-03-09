# 테스트 케이스

## TC-1: Pydantic 스키마 유효성
- 입력: TranscriptRequest(url="https://youtube.com/watch?v=test123")
- 기대결과: 객체 생성 성공, url 필드 정상
- 검증명령: `cd server && python -m pytest tests/test_schemas.py -v`
- 결과:

## TC-2: YouTube 서비스 (mock)
- 입력: video_id="test123"
- 기대결과: title, thumbnail, transcript 포함된 dict 반환
- 검증명령: `cd server && python -m pytest tests/test_youtube.py -v`
- 결과:

## TC-3: POST /api/v1/transcript 엔드포인트
- 입력: POST {"url": "https://youtube.com/watch?v=test123"}
- 기대결과: 200 OK, video_id/title/thumbnail/transcript 포함
- 검증명령: `cd server && python -m pytest tests/test_api.py::test_transcript -v`
- 결과:

## TC-4: POST /api/v1/summarize 엔드포인트
- 입력: POST {"video_id": "test", "transcript": "...", "title": "..."}
- 기대결과: 200 OK, summary/key_points 포함
- 검증명령: `cd server && python -m pytest tests/test_api.py::test_summarize -v`
- 결과:

## TC-5: POST /api/v1/chat 엔드포인트
- 입력: POST {"video_id": "test", "transcript": "...", "question": "무슨 내용?"}
- 기대결과: 200 OK, answer 포함
- 검증명령: `cd server && python -m pytest tests/test_api.py::test_chat -v`
- 결과:

## TC-6: Flutter analyze 통과
- 입력: flutter analyze
- 기대결과: No issues found
- 검증명령: `cd app && flutter analyze`
- 결과:
