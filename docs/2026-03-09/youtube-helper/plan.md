# 구현 계획

## 요청 요약
- YouTube URL 입력 → 자막 추출 → AI 요약 → AI 채팅 기능을 제공하는 앱
- Flutter 앱 + FastAPI 서버 + Gemini AI
- 캐싱된 데이터에 유튜브 썸네일/타이틀 필수

## 기능 목록

### 기능 1: FastAPI 서버 기본 구조
- 설명: FastAPI 프로젝트 셋업 (server/ 디렉토리)
- 핵심 요구사항:
  - pyproject.toml / requirements.txt 의존성 관리
  - CORS 설정
  - API 라우터 구조 (/api/v1/)
  - Gemini API 클라이언트 설정
  - 에러 핸들링 미들웨어

### 기능 2: 자막 추출 API
- 설명: POST /api/v1/transcript — YouTube URL → 자막 + 메타데이터 반환
- 핵심 요구사항:
  - youtube-transcript-api로 자막 추출
  - YouTube 영상 메타데이터 추출 (제목, 썸네일 URL, 길이)
  - 응답: { video_id, title, thumbnail_url, transcript, duration }
  - URL 유효성 검증

### 기능 3: AI 요약 API
- 설명: POST /api/v1/summarize — 자막 텍스트 → Gemini 요약 반환
- 핵심 요구사항:
  - Gemini API로 자막 요약 생성
  - 구조화된 요약 (동영상 요약, 핵심 요점)
  - 응답: { summary, key_points[] }

### 기능 4: AI 채팅 API
- 설명: POST /api/v1/chat — 자막 기반 Q&A
- 핵심 요구사항:
  - 자막 컨텍스트 기반 질문 응답
  - 대화 히스토리 지원
  - 응답: { answer, sources[] }

### 기능 5: Flutter 앱 기본 구조
- 설명: Flutter 프로젝트 셋업 (app/ 디렉토리)
- 핵심 요구사항:
  - 하단 네비게이션 (홈, 히스토리, 설정)
  - 라우팅 구조
  - HTTP 클라이언트 서비스
  - 상태 관리 (Provider 또는 Riverpod)

### 기능 6: 홈 화면 UI
- 설명: YouTube URL 입력 + 요약 요청 + 결과 표시
- 핵심 요구사항:
  - URL 입력 필드 + 붙여넣기 아이콘
  - 빨간색 "요약하기" 버튼
  - 진행 프로그레스바 (AI 요약 중... N%)
  - 결과 카드: 유튜브 썸네일 + 타이틀 + 요약 미리보기
  - "전문 보기" 버튼 → 상세 화면 이동

### 기능 7: 상세 화면 UI
- 설명: 요약 상세 + 채팅
- 핵심 요구사항:
  - 탭: 스크립트 전문 / 동영상 요약 / 핵심 요점 / 챗봇
  - 채팅 FAB 버튼
  - 채팅 인터페이스 (메시지 입력 + 응답 표시)

### 기능 8: 히스토리 화면 UI
- 설명: 이전 요약 기록 목록
- 핵심 요구사항:
  - 최근 요약 리스트 (썸네일 + 타이틀 + 날짜 + 요약 미리보기)
  - 로컬 저장 (SharedPreferences 또는 SQLite)
  - 빈 상태: "아직 요약한 영상이 없어요" 메시지
  - 항목 탭 → 상세 화면 이동

## 기술 고려사항
- youtube-transcript-api: 자막 미제공 영상 대비 에러 핸들링 필요
- YouTube 메타데이터: yt-dlp 또는 pytube로 제목/썸네일 추출 (별도 API 키 불필요)
- Gemini API: google-generativeai 패키지, API 키 환경변수 관리
- Flutter HTTP: http 또는 dio 패키지
- 캐싱: 서버 측 인메모리 또는 앱 측 로컬 저장소
- 썸네일 URL: `https://img.youtube.com/vi/{video_id}/hqdefault.jpg` 형식으로 직접 구성 가능

## QA 고려사항
- 서버 API 단위 테스트: pytest + httpx (TestClient)
- 엣지 케이스: 잘못된 URL, 자막 없는 영상, 네트워크 오류, 빈 자막
- Gemini API 모킹: 테스트 시 실제 API 호출 방지
- Flutter 위젯 테스트: 주요 화면 렌더링 검증
- 통합 테스트: API 요청 → 응답 → UI 업데이트 흐름
