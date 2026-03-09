# YouTube Helper - 개발 계획

## 개요
YouTube URL을 입력하면 자막을 추출하고 AI(Gemini)가 요약/정리/채팅해주는 앱.
Flutter 앱 + FastAPI 서버 구성.

## 아키텍처

### 서버 (server/)
```
server/
├── main.py              # FastAPI 앱 엔트리포인트
├── requirements.txt     # 의존성
├── api/
│   └── v1/
│       ├── __init__.py
│       └── endpoints.py # transcript, summarize, chat 엔드포인트
├── services/
│   ├── __init__.py
│   ├── youtube.py       # 자막 추출 + 메타데이터(썸네일, 타이틀) 가져오기
│   ├── summarizer.py    # Gemini 요약
│   └── chat.py          # Gemini 채팅 (자막 기반 Q&A)
├── models/
│   ├── __init__.py
│   └── schemas.py       # Pydantic 모델 (요청/응답)
└── tests/
    ├── __init__.py
    ├── test_endpoints.py
    └── test_services.py
```

### 앱 (app/)
```
app/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── models/
    │   └── video_summary.dart    # 비디오 요약 데이터 모델
    ├── services/
    │   ├── api_service.dart      # FastAPI 통신
    │   └── storage_service.dart  # 로컬 캐싱 (SharedPreferences)
    ├── screens/
    │   ├── home_screen.dart      # URL 입력 + 요약 표시
    │   ├── detail_screen.dart    # 요약/스크립트/채팅 탭
    │   ├── history_screen.dart   # 히스토리 목록
    │   └── settings_screen.dart  # 설정
    └── widgets/
        ├── video_card.dart       # 썸네일+타이틀+요약 카드
        ├── summary_view.dart     # 요약 표시 위젯
        ├── chat_bubble.dart      # 채팅 말풍선
        └── loading_indicator.dart # 로딩 프로그레스
```

## API 설계

### POST /api/v1/transcript
```json
// Request
{"url": "https://youtube.com/watch?v=..."}
// Response
{
  "video_id": "...",
  "title": "...",
  "thumbnail_url": "https://img.youtube.com/vi/.../maxresdefault.jpg",
  "transcript": "전체 자막 텍스트",
  "language": "ko"
}
```

### POST /api/v1/summarize
```json
// Request
{"video_id": "...", "transcript": "..."}
// Response
{
  "video_id": "...",
  "summary": "요약 텍스트",
  "key_points": ["포인트1", "포인트2", ...],
  "sections": [{"title": "섹션명", "content": "내용"}, ...]
}
```

### POST /api/v1/chat
```json
// Request
{"video_id": "...", "transcript": "...", "message": "질문", "history": []}
// Response
{"reply": "답변 텍스트"}
```

## 개발 Phase

### Phase 1: 서버 기초 (server/)
- Step 1: FastAPI 프로젝트 구조 + requirements.txt + Pydantic 스키마
- Step 2: YouTube 자막 추출 서비스 (youtube-transcript-api) + 메타데이터(타이틀, 썸네일)
- Step 3: 3개 API 엔드포인트 구현 (/transcript, /summarize, /chat)
- Step 4: Gemini 서비스 구현 (summarizer.py, chat.py)
- Step 5: 서버 테스트 작성

### Phase 2: Flutter 앱 기초 (app/)
- Step 1: Flutter 프로젝트 생성 + 의존성 설정
- Step 2: 데이터 모델 + API 서비스 + 로컬 스토리지 서비스
- Step 3: 홈 화면 (URL 입력 + 요약하기 버튼 + 로딩 + 결과 카드)
- Step 4: 상세 화면 (요약/스크립트/채팅 탭)
- Step 5: 히스토리 화면 (썸네일+타이틀 포함 캐싱 목록)
- Step 6: 하단 네비게이션 + 설정 화면 + UI 마무리

## 디자인 스펙 (스크린샷 기반)

### 색상
- Primary: 빨간색 (#FF3B30 계열)
- Background: 흰색
- Card: 연회색 배경, 라운드 코너

### 홈 화면
- 상단: "YouTube Helper" + 로고 + 히스토리 아이콘
- URL 입력 필드 (붙여넣기 아이콘 포함)
- "✦ 요약하기" 버튼 (빨간 그라데이션)
- 로딩: 프로그레스 바 + 퍼센트
- 결과: 썸네일 카드 + 타이틀 + 요약 텍스트 + "전문 보기" 버튼

### 상세 화면
- 탭: 요약 | 스크립트 | 전문
- 동영상 요약 섹션 (불릿 포인트)
- 핵심 포인트 섹션
- 하단 우측: 빨간 채팅 FAB 버튼

### 히스토리 화면
- "최근 요약 기록" 헤더
- 리스트: 썸네일 + 타이틀 + 날짜 + 요약 미리보기
- 빈 상태: "아직 요약한 영상이 없어요" 메시지

### 하단 네비게이션
- 홈 | 히스토리 | 설정 (3탭)

## 핵심 요구사항
- 캐싱된 데이터에 반드시 유튜브 썸네일과 타이틀 포함
- YouTube 메타데이터(title, thumbnail_url)를 transcript 응답에서 함께 반환
- 로컬 캐싱 시 썸네일 URL + 타이틀 함께 저장
