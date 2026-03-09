# Phase 1, Step 2: /api/v1/transcript 엔드포인트

## TC

### TC-1: YouTube 서비스 - video_id 추출
- 입력: 다양한 YouTube URL 형식
- 기대결과: video_id 정상 추출
- 검증명령: `python3 -c "import sys; sys.path.insert(0,'.'); from server.services.youtube import extract_video_id; assert extract_video_id('https://www.youtube.com/watch?v=abc123') == 'abc123'; assert extract_video_id('https://youtu.be/abc123') == 'abc123'; print('OK')"`
- 결과:

### TC-2: transcript 라우터 등록 확인
- 입력: FastAPI 앱의 라우트 목록
- 기대결과: /api/v1/transcript POST 라우트 존재
- 검증명령: `python3 -c "import sys; sys.path.insert(0,'.'); from server.main import app; routes = [r.path for r in app.routes]; assert '/api/v1/transcript' in routes; print('OK')"`
- 결과:

## 구현 내용
(개발 후 기록)
