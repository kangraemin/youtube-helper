# YouTube Helper — dev-bounce 워크플로우 A/B 실험 보고서

> **실험 기간**: 2026-03-08 ~ 2026-03-09
> **방법론**: N=5 자동화 반복 실험 (각 조건 5회, 총 10회)
> **자동화**: `experiment/run-claude.py` (stream-json 양방향 통신) + `experiment/experiment-runner.sh` (오케스트레이터)
> **검증**: `experiment/verify-api-contract.py` (Dart ↔ Python API 계약 자동 검증)

---

## 1. 실험 설계

동일한 요구사항(YouTube 영상 자막 추출 → AI 요약 → 채팅)을 두 가지 방식으로 구현하되, 독립된 git worktree에서 매번 새롭게 시작.

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 개발 방식 | dev-bounce 파이프라인 (intent → planner → dev → qa → verifier) | 자유 개발 + 팀에이전트 구성 지시 |
| 반복 횟수 | **5회** | **5회** |
| 시작점 | `f8e094a` (빈 레포) | `f8e094a` (빈 레포) |
| 기술 스택 | Flutter + FastAPI + Gemini | Flutter + FastAPI + Gemini |
| 격리 방식 | git worktree (`/tmp/experiment-*`) | git worktree (`/tmp/experiment-*`) |
| 타임아웃 | 1,800초 (30분) | 1,800초 (30분) |
| 예산 제한 | $20/run | $20/run |

### 자동화 파이프라인

```
experiment-runner.sh
  ├── git worktree 생성 (f8e094a 기준)
  ├── [with만] ai-bouncer 설치 + experiment override
  ├── run-claude.py (stream-json 양방향 통신)
  │     ├── 프롬프트 전송
  │     ├── AskUserQuestion → 자동 응답
  │     ├── 승인 패턴 감지 → 자동 승인
  │     ├── 완료 감지 → 종료
  │     └── 안전밸브 (40회 auto-continuation)
  ├── evaluate-run.py (메트릭 수집)
  └── 결과 커밋 + 푸시
```

---

## 2. 핵심 결과: API 계약 정합성

**가장 중요한 메트릭** — Dart 프론트엔드가 Python 백엔드의 API 스키마와 일치하는가.

| | `with-dev-bounce` | `without-dev-bounce` |
|--|:-:|:-:|
| **API 계약 통과** | **5/5 (100%)** | **3/5 (60%)** |
| Critical 불일치 | 0건 | 2건 (no2, no5) |
| Warning | 0건 | 1건 (no3) |
| 서버 실행 가능 | 5/5 | 5/5 |

### 개별 실행 결과

| Run | with API | without API |
|-----|:--------:|:-----------:|
| no1 | ✅ 0 critical | ✅ 0 critical |
| no2 | ✅ 0 critical | ❌ **1 critical** |
| no3 | ✅ 0 critical | ⚠️ **1 warning** |
| no4 | ✅ 0 critical | ✅ 0 critical |
| no5 | ✅ 0 critical | ❌ **1 critical** |

### API 불일치 유형 (without-dev-bounce)

without-dev-bounce에서 발생한 API 불일치는 전형적인 **크로스 언어 계약 불일치** 패턴:
- Dart가 보내는 필드명 ≠ Python이 기대하는 필드명 (예: `video_title` vs `title`)
- Dart가 파싱하는 응답 키 ≠ Python이 반환하는 키 (예: `answer` vs `reply`)
- 필수 필드 누락 (Dart에서 미전송, Python에서 ValidationError)

**with-dev-bounce는 5회 모두 0건** — 단계별 구현 + QA + Verifier가 크로스 언어 계약을 자연스럽게 검증.

---

## 3. 시간 및 비용

| | `with-dev-bounce` | `without-dev-bounce` |
|--|:-:|:-:|
| **평균 소요 시간** | **662초 (11분)** | **901초 (15분)** |
| 최소 | 379초 | 331초 |
| 최대 | 883초 | 1,807초 (타임아웃) |
| **평균 비용** | **$7.0** | **$5.8** |
| 총 비용 (5회) | $35.0 | $23.3 (4회, no1 비용 미기록) |
| 타임아웃 | 0회 | 1회 (no1) |

### 개별 실행 데이터

#### with-dev-bounce

| Run | 시간 | 비용 | Auto-respond | API |
|-----|:----:|:----:|:------------:|:---:|
| no1 | 883초 | $17.02 | 15회 | ✅ |
| no2 | 379초 | $3.73 | 31회 | ✅ |
| no3 | 851초 | $5.18 | 2회 | ✅ |
| no4 | 629초 | $5.11 | 13회 | ✅ |
| no5 | 569초 | $3.91 | 2회 | ✅ |

#### without-dev-bounce

| Run | 시간 | 비용 | Auto-respond | API |
|-----|:----:|:----:|:------------:|:---:|
| no1 | 1,807초 | — | 0회 | ✅ |
| no2 | 882초 | $6.35 | 2회 | ❌ |
| no3 | 331초 | $2.85 | 40회 | ⚠️ |
| no4 | 709초 | $3.90 | 2회 | ✅ |
| no5 | 775초 | $10.20 | 17회 | ❌ |

---

## 4. 정량 비교 요약

| 카테고리 | `with-dev-bounce` | `without-dev-bounce` | 승자 |
|---------|:-:|:-:|:---:|
| API 계약 통과율 | 100% | 60% | **with** |
| 서버 실행 가능 | 100% | 100% | 동률 |
| 평균 소요 시간 | 662초 | 901초 | **with** (27% 빠름) |
| 평균 비용 | $7.0 | $5.8 | **without** (17% 저렴) |
| 타임아웃 | 0회 | 1회 | **with** |
| 앱 LOC (중앙값) | 1,362 | 1,704 | — |

> **비용 vs 품질 트레이드오프**: with-dev-bounce는 17% 더 비싸지만, API 계약 통과율이 100% vs 60%로 압도적. 비용 대비 품질 관점에서 with-dev-bounce가 유리.

---

## 5. 아키텍처 비교 (대표 실행 기준)

수동 코드 리뷰 결과 (1회차 기준). N=5 반복에서도 동일한 패턴 관찰.

### Flutter 앱

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 상태관리 | Riverpod + StateNotifier | Riverpod + StateNotifier |
| 모델 | Freezed | Freezed + Hive TypeAdapter |
| API 클라이언트 | raw Map → Provider 파싱 | 타입별 Response 클래스 + ApiException |
| 로컬 저장 | Hive (JSON 문자열) | Hive (TypeAdapter) |
| URL 검증 | 서버 의존 | 클라이언트 UrlValidator |

### FastAPI 백엔드

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 설정 관리 | `os.getenv()` 직접 | `config.py` 분리 |
| Gemini 모델 | gemini-2.0-flash | gemini-2.5-flash |
| 프롬프트 언어 | 다국어 (language 파라미터) | 한국어 고정 |
| temperature | 요약 0.3 / 채팅 0.7 | 미설정 (기본값) |
| 제목 추출 | oEmbed API (안정적) | HTML 파싱 (취약) |

### 설계 품질 평가

- **without-dev-bounce가 우수**: config 분리, Repository 패턴, TypeAdapter, ApiException, UrlValidator, ChatWidget 분리
- **with-dev-bounce가 우수**: API 계약 100% 정합성, 다국어 지원, temperature 튜닝, oEmbed API, 테스트 커버리지 (15 vs 11)

> 결론: without-dev-bounce는 **코드 설계 패턴이 더 성숙**하지만, **크로스 언어 API 계약에서 40% 확률로 실패**. with-dev-bounce는 단계별 검증 덕분에 100% 정합성.

---

## 6. 개발 프로세스 비교

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 워크플로우 | Phase 0(인텐트)→1(계획)→2(승인)→3(개발)→4(검증) | 자유 개발 + 팀에이전트 |
| 커밋 단위 | phase/step별 | 단일 또는 소수 |
| 계획 문서 | plan.md + phase별 step docs | 없음 |
| Gate 시스템 | plan-gate + bash-gate + completion-gate | 없음 |
| QA 검증 | Verifier 3회 연속 통과 필수 | 없음 |
| Hook 스크립트 | 5개 (bash-audit, bash-gate, completion-gate, doc-reminder, plan-gate) | 없음 |

---

## 7. 결론

### 핵심 발견

1. **API 계약 정합성**: with-dev-bounce 100% vs without-dev-bounce 60%. 이것이 가장 큰 차이.
2. **원인 분석**: without-dev-bounce는 프론트엔드와 백엔드를 동시에 생성하면서 필드명이 어긋남. with-dev-bounce는 Phase별 순차 구현 + QA 검증으로 자연스럽게 방지.
3. **시간 효율**: with-dev-bounce가 27% 빠름 (662초 vs 901초). Gate 시스템이 삽질을 줄여줌.
4. **비용**: with-dev-bounce가 17% 더 비쌈 ($7.0 vs $5.8). 검증 단계에 추가 토큰 소모.
5. **안정성**: with-dev-bounce는 타임아웃 0회, without-dev-bounce는 1회.

### 한 줄 요약

> **dev-bounce는 "작동하는 소프트웨어"를 만든다.** 설계 패턴은 without-dev-bounce가 더 성숙하지만, 40% 확률로 API가 깨진다면 의미가 없다.

---

## 8. 실험 재현

### 사전 준비

```bash
# Claude Code CLI 설치 필요
# ai-bouncer는 experiment-runner.sh가 자동 설치

pip install scipy  # Mann-Whitney U 검정 (선택)
```

### 실행

```bash
# N=5 전체 실행 (with + without 각 5회)
./experiment/experiment-runner.sh

# 특정 모드만
./experiment/experiment-runner.sh --mode with --start 1 --end 5

# 드라이런
./experiment/experiment-runner.sh --dry-run

# 결과 재집계
python3 experiment/aggregate-results.py --results-dir experiment/results
```

### 설정 변경

```bash
# experiment/config.env
NUM_RUNS=10          # 반복 횟수
CLAUDE_TIMEOUT=1800  # 타임아웃 (초)
INITIAL_COMMIT=f8e094a  # 시작 커밋
```

---

## 9. 기술 스택

| 영역 | 기술 |
|------|------|
| Frontend | Flutter (Dart) — Riverpod, GoRouter, Hive, Freezed |
| Backend | FastAPI (Python) — Pydantic, Uvicorn |
| AI | Google Gemini (2.0 Flash / 2.5 Flash) |
| 실험 자동화 | Python (stream-json) + Bash (worktree 오케스트레이션) |
| API 검증 | Python AST 기반 Pydantic 스키마 파싱 + Dart HTTP 패턴 매칭 |

## 10. 실행 방법

```bash
# 서버
cd server
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
echo "GEMINI_API_KEY=your-key" > .env
python main.py

# 앱
cd app
flutter pub get
flutter run
```
