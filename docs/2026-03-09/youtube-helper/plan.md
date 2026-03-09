# YouTube Helper — 구현 계획

## 개요
YouTube URL을 입력하면 자막을 추출하고, Gemini AI로 요약/채팅하는 앱.
- **서버**: FastAPI + youtube-transcript-api + Google Gemini
- **앱**: Flutter (iOS/Android)

---

## API 설계

### POST /api/v1/transcript
- Request: `{ "url": "https://youtube.com/watch?v=..." }`
- Response: `{ "video_id": "...", "title": "...", "thumbnail": "...", "transcript": "...", "duration": "..." }`
- youtube-transcript-api로 자막 추출, yt-dlp 또는 pytube로 메타데이터(제목, 썸네일) 추출

### POST /api/v1/summarize
- Request: `{ "video_id": "...", "transcript": "...", "title": "..." }`
- Response: `{ "summary": "...", "key_points": ["...", "..."] }`
- Gemini AI로 요약 + 핵심 포인트 생성

### POST /api/v1/chat
- Request: `{ "video_id": "...", "transcript": "...", "question": "...", "history": [...] }`
- Response: `{ "answer": "..." }`
- 자막 컨텍스트 기반 Q&A

---

## 서버 구조 (server/)

```
server/
├── main.py              # FastAPI app, CORS, router 등록
├── requirements.txt     # 의존성
├── routers/
│   └── api_v1.py        # /api/v1/* 엔드포인트
├── services/
│   ├── youtube.py       # 자막 추출 + 메타데이터
│   ├── summarizer.py    # Gemini 요약
│   └── chat.py          # Gemini 채팅
├── schemas/
│   └── models.py        # Pydantic request/response 모델
└── tests/
    ├── test_youtube.py
    ├── test_summarizer.py
    └── test_api.py
```

---

## Flutter 앱 구조 (app/)

```
app/
├── pubspec.yaml
└── lib/
    ├── main.dart                 # 앱 진입점, 라우팅, 테마
    ├── models/
    │   └── video_summary.dart    # 비디오 요약 데이터 모델
    ├── services/
    │   └── api_service.dart      # FastAPI 서버 통신
    ├── providers/
    │   └── video_provider.dart   # 상태 관리 (ChangeNotifier)
    └── screens/
        ├── home_screen.dart      # 홈: URL 입력 + 요약 결과
        ├── detail_screen.dart    # 상세: 요약/스크립트/채팅 탭
        └── history_screen.dart   # 히스토리: 최근 요약 목록
```

---

## 화면 설계 (디자인 참고)

### 홈 화면
- 상단: "YouTube Helper" 타이틀 + 히스토리 아이콘
- YouTube URL 입력 필드 (붙여넣기 버튼)
- 빨간색 "✨ 요약하기" 버튼
- 진행 중: 프로그레스 바 + "AI 요약 중... N%"
- 결과: 썸네일 + 제목 + 요약 미리보기 + "전문 보기" 버튼
- 하단 네비게이션: 홈 / 히스토리 / 설정

### 상세 화면
- 탭: 요약 / 스크립트 / 전문
- 동영상 요약 섹션
- 핵심 포인트 섹션
- 스크립트 일부 섹션
- 하단 FAB: AI 채팅

### 히스토리 화면
- "최근 요약 기록" 리스트
- 각 항목: 썸네일 + 제목 + 날짜 + 요약 미리보기
- 빈 상태: "아직 요약한 영상이 없어요"

---

## 개발 Phase 분해

### Phase 1: 서버 기반 구축
- FastAPI 프로젝트 설정 (main.py, requirements.txt)
- Pydantic 스키마 정의 (schemas/models.py)
- YouTube 자막/메타데이터 서비스 (services/youtube.py)
- API 라우터 — transcript 엔드포인트 (routers/api_v1.py)

### Phase 2: 서버 AI 기능
- Gemini 요약 서비스 (services/summarizer.py)
- Gemini 채팅 서비스 (services/chat.py)
- summarize, chat 엔드포인트 추가

### Phase 3: Flutter 앱 기본 구조
- Flutter 프로젝트 생성 + 의존성 설정
- 데이터 모델 + API 서비스
- 상태 관리 (Provider)
- 라우팅 + 테마 설정

### Phase 4: Flutter 홈 화면
- URL 입력 + 요약 버튼
- 프로그레스 표시
- 결과 카드 (썸네일 + 제목 + 요약)

### Phase 5: Flutter 상세 + 히스토리 화면
- 상세 화면 (탭뷰: 요약/스크립트/채팅)
- 히스토리 화면 (로컬 저장 + 리스트)
- 하단 네비게이션 바

---

## 검증 방법
- 서버: pytest로 각 엔드포인트 테스트 (mock YouTube/Gemini)
- 앱: Flutter analyze + 빌드 검증
- API 계약: schemas/models.py 기준 request/response 검증
