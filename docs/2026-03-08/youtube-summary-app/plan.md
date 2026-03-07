# YouTube Summary App - 전체 구현 계획

## Context
YouTube 링크를 입력하면 자막을 추출하고, Gemini AI가 요약/정리해주는 모바일 앱.
현재 브랜치(with-dev-bounce)는 빈 스캐폴드 상태. 처음부터 새로 구현.

## 참고 프로젝트
- **brainTracy** (`/Users/ram/programming/vibecoding/brainTracy`): Flutter 아키텍처 참고 (Clean Architecture + Riverpod + GoRouter + Freezed + Hive + Material 3)
- **coinbot** (`/Users/ram/programming/vibecoding/coinbot`): 배포 참고 (Oracle Cloud VM `158.179.166.232`, rsync, systemd, ubuntu 사용자)
- **디자인** (`/Users/ram/Downloads/stitch 2/`): 3개 화면 디자인 (Home, Summary Detail, History)

## 스택
- **Backend**: FastAPI + uvicorn + google-genai + youtube-transcript-api
- **Frontend**: Flutter (brainTracy 아키텍처 따름) + Riverpod + GoRouter + Freezed + Hive
- **AI**: Gemini 2.0 Flash
- **배포**: Oracle Cloud VM (158.179.166.232), systemd, rsync

## 디자인 스펙
- **Primary Color**: `#ff0000` (YouTube Red)
- **Background**: `#f8f5f5` (light), `#230f0f` (dark)
- **Font**: Work Sans + Noto Sans KR
- **Icons**: Material Symbols Outlined
- **Bottom Nav**: 홈, 기록, 설정 (3탭)
- **히스토리 아이템**: YouTube 썸네일 + 타이틀 필수 표시

### 화면 구성 (디자인 기반)
1. **Home**: URL 입력 + 붙여넣기 버튼 + 로딩(프로그레스 바) + 결과 카드(썸네일, 제목, 요약)
2. **Summary Detail**: 비디오 썸네일 + 탭(요약/스크립트 전문) + 타임스탬프 트랜스크립트 + 복사 FAB
3. **History**: 스와이프 삭제 + 썸네일/제목/시간 리스트 + 빈 상태 일러스트

## 핵심 설계
- **Stateless 서버**: DB 없음. 모든 상태는 클라이언트 Hive에서 관리
- **히스토리 저장 시 썸네일 URL + 타이틀 필수 포함**
- **Clean Architecture**: brainTracy 패턴 따름 (features/ → domain/infrastructure/application/presentation)

---

## Phase 1: Backend 기반 (FastAPI + 트랜스크립트)

### 파일
- `server/main.py`: FastAPI 앱, CORS, uvicorn runner
- `server/models/__init__.py`
- `server/models/schemas.py`: Pydantic 모델 (TranscriptRequest/Response, SummarizeRequest/Response, ChatRequest/Response, ChatMessage, ErrorResponse)
- `server/services/__init__.py`
- `server/services/transcript_service.py`: extract_video_id(), get_video_title(), get_transcript()
- `server/routers/__init__.py`
- `server/routers/api_v1.py`: POST /api/v1/transcript
- `server/requirements.txt`: 의존성 고정
- `server/tests/__init__.py`, `server/tests/conftest.py`, `server/tests/test_transcript.py`

### 검증
- `pytest tests/test_transcript.py -v`
- curl로 /api/v1/transcript 수동 테스트

---

## Phase 2: Backend AI + 배포 (Gemini 요약/채팅 + systemd)

### 파일
- `server/services/gemini_service.py`: summarize_transcript(), chat_about_video()
- `server/routers/api_v1.py`: POST /api/v1/summarize, POST /api/v1/chat 추가
- `server/tests/test_summarize.py`: mock 기반 테스트
- `deploy.sh`: rsync 배포 스크립트 (coinbot 패턴)
- `youtube-helper.service`: systemd 서비스 파일

### 배포 구성 (coinbot 참고)
- 서버: `158.179.166.232` (ubuntu)
- 작업 디렉토리: `/home/ubuntu/youtube-helper`
- rsync 제외: `.env`, `venv/`, `__pycache__/`, `.git/`
- systemd: `youtube-helper.service` (uvicorn, auto-restart)

### 검증
- `pytest tests/ -v`
- curl로 /api/v1/summarize, /api/v1/chat 수동 테스트
- `bash deploy.sh` 배포 확인

---

## Phase 3: Flutter 앱 기반 (프로젝트 + 네비게이션 + 홈)

### 파일 (brainTracy Clean Architecture 따름)
- `app/` (flutter create)
- `app/pubspec.yaml`: flutter_riverpod, go_router, freezed, hive_flutter, http, flutter_markdown
- `app/lib/main.dart`: Hive 초기화, ProviderScope
- `app/lib/app.dart`: MaterialApp.router, 테마
- `app/lib/core/theme/app_theme.dart`: YouTube Red 기반 Material 3 테마 (light/dark)
- `app/lib/core/constants/api_constants.dart`: 서버 URL
- `app/lib/routing/app_router.dart`: GoRouter (/, /summary, /history, /settings)
- `app/lib/features/summarize/domain/entities/`: VideoSummary, ChatMessage (Freezed)
- `app/lib/features/summarize/infrastructure/`: ApiService, StorageService
- `app/lib/features/summarize/application/`: Riverpod providers
- `app/lib/features/summarize/presentation/home_screen.dart`: URL 입력 + 결과 카드
- `app/lib/features/summarize/presentation/widgets/`: video_result_card, loading_progress

### 검증
- `flutter run` 후 홈 화면 렌더링 확인

---

## Phase 4: Flutter 기능 완성 (요약 상세 + 히스토리 + 설정)

### 파일
- `app/lib/features/summarize/presentation/summary_detail_screen.dart`: 썸네일 + 탭(요약/스크립트) + 채팅 + 복사 FAB
- `app/lib/features/history/presentation/history_screen.dart`: 썸네일+타이틀+시간 리스트, 스와이프 삭제, 빈 상태
- `app/lib/features/history/application/`: history providers
- `app/lib/features/history/infrastructure/`: Hive 저장소
- `app/lib/features/settings/presentation/settings_screen.dart`: 다크모드 토글, 서버 URL, 히스토리 삭제
- `app/lib/features/settings/application/`: settings providers
- `app/lib/features/summarize/presentation/widgets/chat_bubble.dart`
- `app/lib/features/summarize/presentation/widgets/transcript_view.dart`: 타임스탬프 트랜스크립트

### 검증
- 전체 플로우: URL 입력 → 요약 → 채팅 → 저장 → 히스토리(썸네일+타이틀 확인) → 설정
