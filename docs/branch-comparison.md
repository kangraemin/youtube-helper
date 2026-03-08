# 브랜치 코드 품질 비교 보고서

> 분석일: 2026-03-08  
> 대상: YouTube Helper (Flutter + FastAPI)  
> 방법: git worktree 기반 격리 환경에서 전체 소스 코드 전수조사  
> 검증: 모든 버그는 실제 코드에서 라인 번호와 함께 확인됨. 오탐 제거를 위해 2차 전수조사 실시.

---

## 1. 조사 범위

두 브랜치의 모든 소스 파일을 읽고, 특히 Dart ↔ Python 간 API 계약을 필드 단위로 대조함.

| 브랜치 | 커밋 수 | Dart 파일 | Python 파일 |
|--------|:------:|:---------:|:----------:|
| `with-dev-bounce` | 12 | 21 | 6 |
| `without-dev-bounce` | 1 | 18 | 8 |

---

## 2. API 계약 검증 결과

두 브랜치 모두 **동일한 Dart API 클라이언트**(`summary_api_service.dart`)와 **동일한 Python 스키마 구조**(`schemas.py`)를 사용함. API 계약 불일치는 양쪽 공통.

### 2.1 `/transcript` 엔드포인트

| | Dart (요청) | Python (수신) | 일치 |
|--|------------|-------------|:---:|
| 요청 필드 | `{'url': url}` | `TranscriptRequest(url: str)` | ✅ |

| | Dart (파싱) | Python (응답) | 일치 |
|--|------------|-------------|:---:|
| `video_id` | `json['video_id']` | `video_id: str` | ✅ |
| `video_title` | `json['video_title']` | **`title: str`** | ❌ 필드명 다름 |
| `transcript` | `json['transcript']` | `transcript: str` | ✅ |
| - | (파싱 안함) | `thumbnail_url: str` | ⚠️ 무시 |
| - | (파싱 안함) | `source: str` | ⚠️ 무시 |

**결과**: Dart가 `json['video_title']`을 읽지만 Python은 `title`로 반환 → **null → `as String` 캐스팅 실패**

### 2.2 `/summarize` 엔드포인트

| | Dart (전송) | Python (요구) | 일치 |
|--|------------|-------------|:---:|
| `transcript` | ✅ 전송 | `transcript: str` | ✅ |
| `video_title` | ❌ **미전송** | `video_title: str` (필수) | ❌ |

| | Dart (파싱) | Python (응답) | 일치 |
|--|------------|-------------|:---:|
| `summary` | `json['summary']` | `summary: str` | ✅ |

**결과**: 필수 필드 `video_title` 누락 → **422 Unprocessable Entity**

### 2.3 `/chat` 엔드포인트

| | Dart (전송) | Python (요구) | 일치 |
|--|------------|-------------|:---:|
| `question` | ✅ 전송 | — | ❌ Python은 이 필드를 모름 |
| — | ❌ 미전송 | `message: str` (필수) | ❌ |
| `transcript` | ✅ 전송 | `transcript: str` | ✅ |
| `summary` | ✅ 전송 | `summary: str` | ✅ |
| — | ❌ 미전송 | `video_title: str` (필수) | ❌ |
| `history` | ✅ 전송 | `history: list[ChatMessage]` | ✅ |

| | Dart (파싱) | Python (응답) | 일치 |
|--|------------|-------------|:---:|
| `answer` | `json['answer']` | **`reply: str`** | ❌ 필드명 다름 |

**결과**: 필드명 불일치 2건 + 필수 필드 누락 2건 → **422 + 파싱 실패**

### 2.4 Python 내부 함수 호출 (두 브랜치 공통)

| 호출 (api_v1.py) | 함수 정의 | 파라미터 일치 |
|------------------|----------|:----------:|
| `transcript_service.extract_video_id(req.url)` | `def extract_video_id(url: str)` | ✅ |
| `transcript_service.get_video_title(video_id)` | `async def get_video_title(video_id: str)` | ✅ |
| `transcript_service.get_transcript(video_id)` | `def get_transcript(video_id: str) -> tuple[str, str]` | ✅ |
| `gemini_service.summarize_transcript(req.transcript, req.video_title)` | `def summarize_transcript(transcript: str, video_title: str)` | ✅ |
| `gemini_service.chat(transcript=..., summary=..., video_title=..., message=..., history=...)` | `def chat(transcript, summary, video_title, message, history)` | ✅ |

**결과**: Python 내부 호출은 **모두 정상**. 함수명, 파라미터명, 순서 모두 일치.

---

## 3. 확인된 버그 목록

### 3.1 공통 버그 (두 브랜치 동일)

두 브랜치가 동일한 `summary_api_service.dart`와 `schemas.py`를 사용하므로 아래 버그는 양쪽 모두 존재.

| # | 버그 | Dart 코드 | Python 코드 | 심각도 |
|---|------|----------|-----------|:-----:|
| **B1** | `/transcript` 응답 필드명 불일치 | `json['video_title']` (L21) | `title: str` (schemas.py:10) | HIGH |
| **B2** | `/summarize` 필수 필드 누락 | `{'transcript': transcript}` (L83) | `video_title: str` 필수 (schemas.py:18) | CRITICAL |
| **B3** | `/chat` 요청 필드명 불일치 | `'question': question` (L108) | `message: str` (schemas.py:34) | CRITICAL |
| **B4** | `/chat` 필수 필드 누락 | video_title 미전송 | `video_title: str` 필수 (schemas.py:33) | CRITICAL |
| **B5** | `/chat` 응답 필드명 불일치 | `json['answer']` (L46) | `reply: str` (schemas.py:39) | CRITICAL |
| **B6** | Dart `?history` 문법 | `'history': ?history` (L111) | - | CRITICAL |

> **B6 보충**: `'history': ?history`는 유효하지 않은 Dart 문법. `with-dev-bounce`에서도 이 파일이 존재하며 동일한 코드가 있음. 단, `with-dev-bounce`의 실제 채팅 호출 경로(`chat_widget.dart`)가 이 메서드를 사용하는지 여부에 따라 실제 영향이 달라질 수 있음.

### 3.2 `without-dev-bounce` 전용 버그

전수조사 결과, `without-dev-bounce`에서만 발견된 **추가 Critical 버그는 없음**.

초기 분석에서 보고된 아래 3건은 모두 **오탐으로 확인**:
- ~~`summarize_transcript()` 파라미터 순서 역전~~ → 실제 순서 정상
- ~~`gemini_service.chat()` 함수 미존재~~ → 함수 실제 존재
- ~~`get_transcript()` 반환 타입 불일치~~ → `tuple[str, str]` 반환, 타입 일치

### 3.3 `without-dev-bounce` 전용 비버그 차이점

| 항목 | without-dev-bounce | with-dev-bounce |
|------|-------------------|----------------|
| 서버 config | `config.py` 분리 ✅ | 하드코딩 |
| 상태 관리 | `ProcessingStep` enum ✅ | `SummaryState` copyWith |
| 에러 처리 | `ApiException` 커스텀 예외 ✅ | 일반 Exception |
| Hive 초기화 실패 | 전체 데이터 삭제 ⚠️ | 에러 핸들링 |
| Repository 패턴 | 추상화 ✅ | 직접 구현 |

---

## 4. 두 브랜치의 실질적 차이

### 4.1 버그 수는 동일

**두 브랜치의 API 계약 버그는 완전히 동일**합니다. 같은 `summary_api_service.dart`를 사용하고, 같은 Python 스키마를 사용하기 때문입니다.

| | with-dev-bounce | without-dev-bounce |
|--|:-:|:-:|
| Critical 버그 | 5 (B2~B6) | 5 (B2~B6) |
| High 버그 | 1 (B1) | 1 (B1) |
| **합계** | **6** | **6** |

### 4.2 진짜 차이: 개발 프로세스

| 항목 | with-dev-bounce | without-dev-bounce |
|------|:-:|:-:|
| 커밋 수 | 12 | 1 |
| 커밋 이력 추적 | ✅ 가능 | ❌ 불가 |
| Phase 문서 | ✅ 있음 | ❌ 없음 |
| 배포 스크립트 | 39줄 (테스트 포함) | 21줄 (테스트 없음) |
| Python 테스트 | 14개 | 8개 |
| 에이전트 품질 게이트 | ✅ 7개 에이전트 | ❌ 없음 |

### 4.3 진짜 차이: 설계 품질

| 항목 | with-dev-bounce | without-dev-bounce |
|------|:-:|:-:|
| 서버 설정 관리 | 하드코딩 | `config.py` 분리 ✅ |
| 상태 머신 명확성 | 중간 | `ProcessingStep` enum ✅ |
| 에러 처리 체계 | 일반 Exception | `ApiException` ✅ |
| 저장소 추상화 | 직접 구현 | Repository 패턴 ✅ |
| Gemini 프롬프트 | 다국어 지원, temperature 설정 ✅ | 한국어 고정 |
| Hive 초기화 | 에러 핸들링 ✅ | 전체 삭제 ⚠️ |

---

## 5. 종합 평가

### 5.1 카테고리별 점수

| 카테고리 | with-dev-bounce | without-dev-bounce | 비고 |
|---------|:-:|:-:|------|
| API 정합성 | 2 | 2 | 둘 다 동일하게 깨짐 |
| 아키텍처 | 7.5 | 8 | without: config.py, Repository, enum |
| 에러 처리 | 5 | 6 | without: ApiException |
| 테스트 | 4 | 3 | with: 14개 vs 8개 |
| 개발 프로세스 | 9 | 3 | with: 12커밋, 문서, 품질게이트 |
| 운영/배포 | 8 | 4 | with: 테스트 포함 배포 |
| AI/프롬프트 | 7 | 5 | with: 다국어, temperature |
| **종합** | **6.1** | **4.4** | |

### 5.2 결론

**API 버그는 동일하다.** 두 브랜치 모두 Dart ↔ Python 간 API 계약이 전면적으로 깨져 있으며, 핵심 기능 3개(자막 추출, 요약, 채팅) 모두 정상 작동하지 않는다.

**차이는 프로세스와 설계에 있다.**

- `with-dev-bounce`는 **개발 프로세스**(커밋 이력, 문서, 배포, 테스트)에서 압도적으로 우수
- `without-dev-bounce`는 **설계 패턴**(config 분리, 상태 머신, 예외 처리, Repository)에서 소폭 우수

**dev-bounce 워크플로우의 한계**: 단일 언어(Python) 내부의 함수 호출 정합성은 완벽하게 유지했지만, **크로스 언어(Dart ↔ Python) API 계약 검증은 실패**했다. 이는 dev-bounce 파이프라인에 E2E 통합 테스트나 API 스키마 공유(OpenAPI 등)가 없었기 때문이다.
