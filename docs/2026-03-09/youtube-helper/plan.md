# YouTube Helper App

YouTube URL을 입력하면 자막을 추출하고 AI가 요약/정리해주는 앱.

## 기술 스택
- **Server**: FastAPI + youtube-transcript-api + google-generativeai (Gemini)
- **App**: Flutter (Dart)

## 아키텍처

```
Flutter App (app/)
  ├── lib/
  │   ├── main.dart
  │   ├── models/          # 데이터 모델
  │   ├── services/         # API 통신
  │   ├── screens/          # 화면
  │   └── widgets/          # 재사용 위젯
  └── pubspec.yaml

FastAPI Server (server/)
  ├── main.py              # FastAPI 앱 엔트리
  ├── routers/
  │   └── api_v1.py        # API 라우터
  ├── services/
  │   ├── transcript.py    # YouTube 자막 추출
  │   └── ai.py            # Gemini AI 서비스
  ├── models/
  │   └── schemas.py       # Pydantic 모델
  ├── requirements.txt
  └── .env.example
```

## API 명세

### POST /api/v1/transcript
- Request: `{ "url": "https://youtube.com/watch?v=..." }`
- Response: `{ "video_id": "...", "title": "...", "thumbnail_url": "...", "transcript": "...", "duration": "12:45" }`

### POST /api/v1/summarize
- Request: `{ "video_id": "...", "title": "...", "transcript": "..." }`
- Response: `{ "video_id": "...", "summary": "...", "key_points": ["...", "..."] }`

### POST /api/v1/chat
- Request: `{ "video_id": "...", "transcript": "...", "message": "...", "history": [...] }`
- Response: `{ "reply": "..." }`

## 화면 구성 (디자인 참고 기반)

### 1. 홈 화면
- YouTube URL 입력 필드 + 클립보드 붙여넣기 버튼
- "요약하기" 버튼 (빨간색)
- 로딩 프로그레스 바 (AI 요약 중... N%)
- 비디오 카드: 썸네일 + 제목 + 시간
- 요약 미리보기 텍스트
- "전문 보기" 버튼 + 복사 버튼
- 하단 네비게이션: 홈, 히스토리, 설정

### 2. 상세 화면
- 앱바: 뒤로가기 + 제목
- 탭: 요약 / 스크립트 전문
- 동영상 요약 섹션
- 핵심 포인트 섹션
- 플로팅 채팅 버튼

### 3. 히스토리 화면
- 최근 요약 기록 리스트
- 각 항목: 썸네일 + 제목 + 날짜 + 요약 미리보기
- 빈 상태: "아직 요약한 영상이 없어요" 메시지

## 개발 Phase

### Dev Phase 1: Server 기반 구축
- Step 1: 프로젝트 구조 + requirements.txt + FastAPI 앱 설정
- Step 2: Pydantic 모델 (schemas.py) 정의
- Step 3: YouTube 자막 추출 서비스 (transcript.py)
- Step 4: Gemini AI 서비스 (ai.py) - 요약 + 채팅
- Step 5: API 라우터 (api_v1.py) - 3개 엔드포인트
- Step 6: 서버 통합 테스트

### Dev Phase 2: Flutter App 기반 구축
- Step 1: Flutter 프로젝트 생성 + 의존성 설정
- Step 2: 데이터 모델 + API 서비스 클래스
- Step 3: 홈 화면 UI (URL 입력 + 요약 카드)
- Step 4: 상세 화면 UI (요약/스크립트 탭 + 채팅)
- Step 5: 히스토리 화면 UI (로컬 저장 + 목록)
- Step 6: 네비게이션 + 통합

## 검증 기준
- 서버: 3개 API 엔드포인트 응답 스키마 일치
- 앱: 3개 화면 존재, 네비게이션 동작
- 캐싱 데이터에 썸네일/타이틀 포함 필수
