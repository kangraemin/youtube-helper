# Step 2: Router + Main + Tests

## 완료 기준
- server/main.py: FastAPI 앱, CORS, uvicorn
- server/routers/api_v1.py: POST /transcript 엔드포인트
- server/routers/__init__.py 생성
- server/tests/conftest.py: TestClient fixture
- server/tests/test_transcript.py: URL 파싱 + 엔드포인트 테스트
- pytest tests/test_transcript.py -v 통과

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | POST /api/v1/transcript with valid URL (mocked) | 200 + TranscriptResponse | ✅ PASS |
| TC-2 | POST /api/v1/transcript with invalid URL | 400 | ✅ PASS |
| TC-3 | POST /api/v1/transcript with no transcript (mocked) | 404 | ✅ PASS |

## 구현 내용
- `server/main.py`: FastAPI app, CORS(allow all), dotenv, uvicorn runner
- `server/routers/__init__.py`: 빈 파일
- `server/routers/api_v1.py`: POST /transcript (extract_video_id, get_video_title, get_transcript 호출)
- `server/tests/__init__.py`: 빈 파일
- `server/tests/conftest.py`: TestClient fixture (sys.path 설정 포함)
- `server/tests/test_transcript.py`: 10개 테스트 (7개 URL 파싱 + 3개 엔드포인트)

## 빌드
- 명령어: `./venv/bin/python -m pytest tests/test_transcript.py -v`
- 결과: 10/10 통과
