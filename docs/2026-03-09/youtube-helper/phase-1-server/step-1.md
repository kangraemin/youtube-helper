# Phase 1, Step 1: 서버 프로젝트 구조 + 의존성 설정

## TC

### TC-1: 서버 디렉토리 구조 존재
- 입력: server/ 디렉토리 확인
- 기대결과: server/main.py, server/requirements.txt, server/routers/, server/services/, server/schemas.py 존재
- 검증명령: `ls server/main.py server/requirements.txt server/routers/ server/services/ server/schemas.py`
- 결과: ✅

### TC-2: requirements.txt 필수 패키지 포함
- 입력: server/requirements.txt 내용 확인
- 기대결과: fastapi, uvicorn, youtube-transcript-api, google-generativeai, pydantic 포함
- 검증명령: `grep -E 'fastapi|uvicorn|youtube-transcript-api|google-generativeai|pydantic' server/requirements.txt | wc -l`
- 결과: ✅ (5개)

### TC-3: FastAPI 앱 임포트 가능
- 입력: python3 -c "from server.main import app"
- 기대결과: 에러 없이 임포트
- 검증명령: `cd /private/tmp/experiment-with-dev-bounce-no3 && python3 -c "import sys; sys.path.insert(0,'.'); from server.main import app; print('OK')"`
- 결과: ✅

## 구현 내용
- server/ 디렉토리 구조 생성 (routers/, services/, tests/)
- requirements.txt 작성 (fastapi, uvicorn, youtube-transcript-api, google-generativeai 등)
- schemas.py: Pydantic 모델 정의 (Request/Response)
- main.py: FastAPI 앱 + 라우터 등록
- 빈 라우터/서비스 파일 생성
