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
| API 정합성 | 2.0 | 2.0 |
| 아키텍처 | 7.5 | 8.0 |
| 에러 처리 | 5.0 | 6.0 |
| 테스트 | 4.0 | 3.0 |
| 개발 프로세스 | **9.0** | 3.0 |
| 운영/배포 | **8.0** | 4.0 |
| AI/프롬프트 | **7.0** | 5.0 |
| **종합** | **6.1 / 10** | **4.4 / 10** |

### 2.2 버그 현황

두 브랜치 모두 동일한 Dart API 클라이언트를 사용하므로 **API 계약 버그는 동일**.

|  | with-dev-bounce | without-dev-bounce |
|--|:-:|:-:|
| Critical | 5 | 5 |
| High | 1 | 1 |
| **합계** | **6** | **6** |

---

## 3. 발견된 버그 상세 (두 브랜치 공통, 6건)

두 브랜치 모두 동일한 `summary_api_service.dart`와 `schemas.py`를 사용하므로 **API 계약 버그는 완전히 동일**.

| # | 심각도 | 버그 | 위치 | 영향 |
|---|:------:|------|------|------|
| B1 | HIGH | **Transcript 응답 필드명 불일치** | Dart: `json['video_title']` / Python: `title` | null → `as String` 캐스팅 실패 → **자막 추출 후 크래시** |
| B2 | CRITICAL | **Summarize 필수 필드 누락** | Dart: `{'transcript': ...}` / Python: `video_title` 필수 | 422 Validation Error → **요약 기능 불작동** |
| B3 | CRITICAL | **Chat 요청 필드명 불일치** | Dart: `question` / Python: `message` | 422 Validation Error → **채팅 불작동** |
| B4 | CRITICAL | **Chat 필수 필드 누락** | Dart: `video_title` 미전송 / Python: 필수 | 422 Validation Error |
| B5 | CRITICAL | **Chat 응답 필드명 불일치** | Dart: `json['answer']` / Python: `reply` | 파싱 실패 |
| B6 | CRITICAL | **Dart `?history` 문법 에러** | `summary_api_service.dart:111` | 유효하지 않은 Dart 문법 |

> **참고**: 초기 분석에서 `without-dev-bounce` 전용 Critical 버그로 보고된 3건(파라미터 순서 역전, 함수 미존재, 반환 타입 불일치)은 전수조사 결과 **모두 오탐**으로 확인되어 삭제함.

---

## 4. 핵심 교훈

### 실질적 차이

- **API 버그는 동일** — 두 브랜치 모두 Dart ↔ Python 간 API 계약이 전면적으로 깨져 있어 핵심 기능 3개(자막, 요약, 채팅) 모두 불작동
- **Python 내부 호출은 정상** — 두 브랜치 모두 서버 내부 함수 호출(파라미터명, 순서, 타입) 완벽히 일치

### 차이는 프로세스와 설계

- `with-dev-bounce`: **개발 프로세스** 우수 (12커밋, phase 문서, 테스트 14개, 배포 스크립트 포함)
- `without-dev-bounce`: **설계 패턴** 소폭 우수 (config.py 분리, Repository 패턴, ApiException, ProcessingStep enum)

### 결론

> dev-bounce 워크플로우는 **Python 내부 정합성은 완벽히 유지**했지만,
> **크로스 언어(Dart ↔ Python) API 계약 검증은 실패**했다.
> 이는 dev-bounce 파이프라인에 E2E 통합 테스트나 API 스키마 공유(OpenAPI 등)가 없었기 때문이다.

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

- [`docs/branch-comparison.md`](docs/branch-comparison.md) — 전수조사 기반 상세 비교 보고서 (API 계약 필드별 대조표, 오탐 검증 기록 포함)
