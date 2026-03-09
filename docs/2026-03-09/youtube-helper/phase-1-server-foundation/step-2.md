# Step 2: YouTube 서비스 + transcript 엔드포인트

## TC
- youtube.py: extract_transcript(url) → video_id, title, thumbnail, transcript 반환
- api_v1.py: POST /api/v1/transcript 엔드포인트
- 검증: `cd server && python -m pytest tests/ -v`

## 구현
- server/services/youtube.py
- server/routers/api_v1.py
- server/tests/test_api.py

## 결과
✅
