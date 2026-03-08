# YouTube Helper — dev-bounce 워크플로우 비교 실험

> YouTube 동영상 자막을 AI로 요약해주는 Flutter + FastAPI 앱

## 1. 실험 목적

이 레포는 **dev-bounce 워크플로우의 효과를 검증**하기 위한 실험용 레포입니다.

동일한 요구사항(YouTube 요약 앱)을 두 가지 방식으로 구현하고, 코드 품질·버그·개발 프로세스를 정량적으로 비교합니다.

| 브랜치 | 개발 방식 | 커밋 | 설명 |
|--------|----------|:----:|------|
| `main` | - | - | 비교 문서 및 공통 설정 |
| `with-dev-bounce` | 구조화된 점진적 개발 | 12 | intent → planner → dev → qa → verifier 파이프라인 |
| `without-dev-bounce` | 자유 개발 (제약 없음) | 1 | 단일 커밋으로 전체 구현 |

---

## 2. 비교 결과 총괄

> 상세 분석: [`docs/branch-comparison.md`](docs/branch-comparison.md)

### 2.1 종합 점수

| 카테고리 | with-dev-bounce | without-dev-bounce |
|---------|:-:|:-:|
| 아키텍처 | 8.0 | 7.0 |
| 에러 처리 | 4.0 | 4.0 |
| 테스트 | 4.0 | 2.0 |
| 보안 | 4.0 | 4.0 |
| 개발 프로세스 | **9.0** | 3.0 |
| 운영/배포 | **8.0** | 4.0 |
| DX (개발자 경험) | **8.0** | 5.0 |
| AI/프롬프트 | **7.0** | 5.0 |
| 버그 위험도 | **5.0** | 2.0 |
| **종합** | **6.2 / 10** | **4.2 / 10** |

### 2.2 버그 현황

|  | with-dev-bounce | without-dev-bounce |
|--|:-:|:-:|
| Critical | 4 | **7** |
| High | 2 | 2 |
| Medium | 3 | 4 |
| **합계** | **9** | **13** |

---

## 3. 발견된 Critical 버그 상세

### 3.1 공통 Critical 버그 (4건)

두 브랜치 모두에서 발견된 버그. Dart 클라이언트 ↔ Python 서버 간 API 계약이 전면적으로 깨져 있음.

| # | 버그 | 위치 | 영향 |
|---|------|------|------|
| C-1 | **Dart 문법 에러 `?history`** | `summary_api_service.dart:111` | `?history`는 유효하지 않은 Dart 문법. **앱 빌드 자체가 불가능.** `history ?? []`이어야 함 |
| C-2 | **Chat API 필드명 3중 불일치** | Dart: `question`, `answer` / Python: `message`, `reply`, `video_title`(필수) | Dart가 보내는 필드명과 Python이 기대하는 필드명이 모두 다름. 422 Validation Error → **채팅 기능 완전 불작동** |
| C-3 | **Transcript 응답 필드 불일치** | Dart: `json['video_title']` / Python: `title` 반환 | Dart가 `video_title` 키로 파싱하지만 서버는 `title`로 반환. null → `as String` 캐스팅 실패 → **자막 추출 후 크래시** |
| C-4 | **Summarize 요청 필드 누락** | Dart: `{'transcript': ...}` / Python: `transcript` + `video_title` 필요 | 필수 필드 `video_title` 미전송. 422 Validation Error → **요약 기능 불작동** |

### 3.2 `without-dev-bounce` 전용 Critical 버그 (+3건)

dev-bounce 워크플로우 없이 개발한 브랜치에서만 추가로 발견된 서버 로직 버그.

| # | 버그 | 위치 | 영향 |
|---|------|------|------|
| C-5 | **`summarize_transcript()` 파라미터 순서 역전** | `api_v1.py:46` → `gemini_service.py:17` | 호출: `(req.transcript, req.video_title)` / 정의: `(title, full_text)`. **제목에 자막이, 자막에 제목이 들어감** → Gemini가 엉터리 요약 생성 |
| C-6 | **`gemini_service.chat()` 함수 미존재** | `api_v1.py:55` | 라우터가 `gemini_service.chat()`을 호출하지만 실제 함수명은 `chat_about_video()`. **AttributeError → 서버 500 에러** |
| C-7 | **`get_transcript()` 반환 타입 불일치** | `transcript_service.py:42` → `api_v1.py:30` | `list[dict]`를 `str` 필드에 할당. Dart 클라이언트가 문자열로 파싱 시도 → **자막 데이터 파싱 실패** |

---

## 4. 핵심 교훈

### dev-bounce가 예방한 것

`with-dev-bounce`에서는 발견되지 않은 C-5, C-6, C-7 버그가 `without-dev-bounce`에서 발견됨.

- **파라미터 순서 역전** (C-5): 단계별 QA 검증이 호출-정의 간 불일치를 잡아냄
- **함수명 불일치** (C-6): verifier 에이전트가 라우터↔서비스 간 인터페이스 검증
- **반환 타입 불일치** (C-7): 점진적 커밋으로 각 엔드포인트별 동작 확인

### dev-bounce가 예방하지 못한 것

공통 Critical 버그 4건(C-1~C-4)은 두 브랜치 모두에서 발견됨.

- Dart ↔ Python 간 **크로스 언어 API 계약 검증**은 dev-bounce만으로 부족
- E2E 통합 테스트 또는 API 스키마 공유(OpenAPI 등)가 추가로 필요

### 결론

> dev-bounce 워크플로우는 **서버 내부 로직 버그**를 효과적으로 예방했지만,  
> **클라이언트-서버 간 통합 버그**는 별도의 검증 메커니즘이 필요하다.  
> 그럼에도 버그 수 기준 `with-dev-bounce`가 **30% 적은 버그**(9 vs 13)를 보여  
> 구조화된 개발 프로세스의 효과를 입증했다.

---

## 5. 기술 스택

| 영역 | 기술 |
|------|------|
| Frontend | Flutter (Dart) — Riverpod, GoRouter, Hive, Freezed |
| Backend | FastAPI (Python) — Pydantic, Uvicorn |
| AI | Google Gemini 2.0 Flash (요약/채팅) |
| 배포 | rsync + systemd (Oracle Cloud) |

## 6. 프로젝트 구조

```
youtube_helper/
├── app/                    # Flutter 모바일 앱
│   └── lib/
│       ├── core/           # 상수, 테마, URL 검증
│       ├── features/       # 요약, 히스토리, 설정 (Clean Architecture)
│       └── routing/        # GoRouter 네비게이션
├── server/                 # FastAPI 백엔드
│   ├── models/             # Pydantic 요청/응답 스키마
│   ├── routers/            # API v1 엔드포인트
│   ├── services/           # YouTube 자막 추출, Gemini AI
│   └── tests/              # pytest 단위 테스트
└── docs/
    └── branch-comparison.md  # 상세 비교 분석 보고서
```

## 7. 실행 방법

### 서버

```bash
cd server
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
echo "GEMINI_API_KEY=your-key" > .env
python main.py
```

### 앱

```bash
cd app
flutter pub get
flutter run
```

## 8. 관련 문서

- [`docs/branch-comparison.md`](docs/branch-comparison.md) — Part 1: 구조/아키텍처/프로세스 비교 + Part 2: 심층 버그 분석 및 7가지 관점 평가
