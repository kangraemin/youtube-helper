# 구현 계획: YouTube Helper

## 요청 요약
- YouTube URL 입력 → 자막 추출 → AI 요약/정리 앱
- Flutter 앱 + FastAPI 서버 + Gemini AI
- 3개 API 엔드포인트: transcript, summarize, chat

## 디자인 분석

### 홈 화면 (screen _2)
- 상단: "YouTube Helper" 타이틀 + 히스토리 아이콘
- YouTube URL 입력 필드 (클립보드 붙여넣기 버튼)
- "요약하기" 빨간 버튼
- 로딩 프로그레스바 (AI 요약 중... 65%)
- 비디오 썸네일 + 길이 표시
- 비디오 제목
- 요약 텍스트 (따옴표 스타일)
- "전문 보기" + 복사 버튼
- 하단 네비게이션: 홈, 기록, 설정

### 상세 화면 (screen _1)
- 탭: 스크립트 전문 / 동영상 요약 / 핵심 포인트 / 챕터 요약
- 각 섹션별 내용 표시
- 하단 빨간 채팅 FAB 버튼

### 히스토리 화면 (screen _3)
- "최근 요약 기록" 헤더
- 카드 리스트: 썸네일 + 제목 + 날짜 + 요약 미리보기
- 빈 상태: "아직 요약한 영상이 없어요"

## 기능 목록

### 기능 1: FastAPI 서버 (server/)
- POST /api/v1/transcript: YouTube URL → 자막 추출 + 메타데이터(제목, 썸네일)
- POST /api/v1/summarize: 자막 → Gemini AI 요약 (동영상 요약, 핵심 포인트, 챕터 요약)
- POST /api/v1/chat: 자막 기반 Q&A 채팅

### 기능 2: Flutter 앱 - 홈 화면 (app/)
- URL 입력 + 클립보드 붙여넣기
- 요약하기 버튼 → API 호출 → 프로그레스 표시
- 결과 카드: 썸네일, 제목, 요약 텍스트

### 기능 3: Flutter 앱 - 상세 화면
- 4개 탭 (스크립트 전문, 동영상 요약, 핵심 포인트, 챕터 요약)
- 채팅 FAB → 채팅 화면

### 기능 4: Flutter 앱 - 히스토리 화면
- 로컬 저장된 요약 기록 리스트
- 썸네일 + 제목 필수 표시
- 날짜별 정렬

### 기능 5: Flutter 앱 - 채팅 화면
- 자막 기반 Q&A 대화
- 메시지 입력 + 응답 표시

## 기술 고려사항
- youtube-transcript-api로 자막 추출
- yt-dlp 또는 YouTube oEmbed API로 메타데이터(제목, 썸네일) 추출
- google-generativeai SDK로 Gemini 호출
- Flutter: http 패키지, shared_preferences 또는 sqflite로 로컬 캐싱
- 썸네일 URL: `https://img.youtube.com/vi/{video_id}/hqdefault.jpg` 패턴 활용

## QA 고려사항
- API 응답 스키마 검증 (transcript, summarize, chat)
- 유효하지 않은 YouTube URL 에러 핸들링
- 자막 없는 영상 처리
- Gemini API 키 미설정 시 에러
- 히스토리 캐시에 썸네일/제목 누락 방지

## 개발 Phase 구조

### Phase 1: FastAPI 서버 기본 구조
- Step 1: 프로젝트 구조 + 의존성 설정
- Step 2: /api/v1/transcript 엔드포인트
- Step 3: /api/v1/summarize 엔드포인트
- Step 4: /api/v1/chat 엔드포인트

### Phase 2: Flutter 앱 기본 구조
- Step 1: Flutter 프로젝트 생성 + 의존성
- Step 2: 앱 테마 + 네비게이션 구조
- Step 3: API 서비스 클래스

### Phase 3: Flutter 홈 화면
- Step 1: URL 입력 + 요약하기 UI
- Step 2: 결과 카드 (썸네일, 제목, 요약)
- Step 3: 로딩 상태 + 프로그레스

### Phase 4: Flutter 상세 화면
- Step 1: 탭 뷰 (스크립트, 요약, 핵심, 챕터)
- Step 2: 채팅 FAB + 채팅 화면

### Phase 5: Flutter 히스토리 화면
- Step 1: 로컬 저장소 (캐싱)
- Step 2: 히스토리 리스트 UI (썸네일 + 제목 필수)

## 변경 파일 예상

### server/
- `requirements.txt`
- `main.py` (FastAPI 앱)
- `routers/transcript.py`
- `routers/summarize.py`
- `routers/chat.py`
- `services/youtube.py`
- `services/gemini.py`
- `schemas.py`

### app/
- `pubspec.yaml`
- `lib/main.dart`
- `lib/services/api_service.dart`
- `lib/models/` (데이터 모델)
- `lib/screens/home_screen.dart`
- `lib/screens/detail_screen.dart`
- `lib/screens/history_screen.dart`
- `lib/screens/chat_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/widgets/` (공통 위젯)

### 테스트
- `server/tests/test_transcript.py`
- `server/tests/test_summarize.py`
- `server/tests/test_chat.py`
