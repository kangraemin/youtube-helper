# Step 1: 프로젝트 구조 + requirements.txt + FastAPI 앱 설정

## TC-1: 서버 디렉토리 구조 확인
- 입력: `ls server/`
- 기대결과: main.py, routers/, services/, models/, requirements.txt 존재
- 결과: ✅ main.py, routers/, services/, models/, requirements.txt 모두 존재

## TC-2: requirements.txt 핵심 패키지
- 입력: `cat server/requirements.txt`
- 기대결과: fastapi, uvicorn, youtube-transcript-api, google-generativeai, pydantic 포함
- 결과: ✅ 모든 패키지 포함

## TC-3: FastAPI 앱 임포트
- 입력: `cd server && python3 -c "from main import app; print(type(app))"`
- 기대결과: `<class 'starlette.applications.Starlette'>` 또는 FastAPI 인스턴스
- 결과: ✅ `<class 'fastapi.applications.FastAPI'>` + 3개 API 라우트 등록 확인
