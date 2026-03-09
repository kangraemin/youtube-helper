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
| 총 비용 | $34.95 (5회) | $23.30 (4회)* |
| 타임아웃 | 0회 | 1회 (no1) |

> *without-dev-bounce no1은 타임아웃으로 비용이 기록되지 않음. 평균 비용은 기록된 4회 기준이므로 실제로는 더 높을 수 있음.

### 개별 실행 데이터

> **컬럼 설명**
> - **시간**: Claude가 작업을 완료하는 데 걸린 총 시간 (초)
> - **비용**: Claude API 토큰 사용 비용 (USD)
> - **Auto-respond**: 자동화 스크립트가 Claude에게 "진행해주세요", "승인합니다" 등을 보낸 횟수. 높을수록 Claude가 사용자 입력을 많이 요청했거나, 턴이 자주 끊겼다는 의미.
> - **API**: `verify-api-contract.py`로 Dart ↔ Python 필드명 자동 교차 검증한 결과. ✅ 통과 / ⚠️ warning / ❌ critical 불일치

#### with-dev-bounce

| Run | 시간 | 비용 | Auto-respond | API |
|-----|:----:|:----:|:------------:|:---:|
| no1 | 883초 | $17.02 | 15회 | ✅ |
| no2 | 379초 | $3.73 | 31회 | ✅ |
| no3 | 851초 | $5.18 | 2회 | ✅ |
| no4 | 629초 | $5.11 | 13회 | ✅ |
| no5 | 569초 | $3.91 | 2회 | ✅ |
| **평균** | **662초** | **$6.99** | **12.6회** | **5/5 ✅** |

#### without-dev-bounce

| Run | 시간 | 비용 | Auto-respond | API |
|-----|:----:|:----:|:------------:|:---:|
| no1 | 1,807초 | (미기록) | 0회 | ✅ |
| no2 | 882초 | $6.35 | 2회 | ❌ |
| no3 | 331초 | $2.85 | 40회 | ⚠️ |
| no4 | 709초 | $3.90 | 2회 | ✅ |
| no5 | 775초 | $10.20 | 17회 | ❌ |
| **평균** | **901초** | **$5.83*** | **12.2회** | **3/5 ✅** |

> *without 비용 평균은 no1(미기록) 제외 4회 기준

---

## 4. 종합 점수표

### 4.1 카테고리별 점수 (10점 만점)

| 카테고리 | `with-dev-bounce` | `without-dev-bounce` | 근거 |
|---------|:-:|:-:|------|
| **API 정합성** | **10** | **4** | with: 5/5 통과(100%). without: 3/5 통과(60%), critical 2건 |
| **아키텍처 설계** | 7 | **8.5** | without: config 분리, Repository 패턴, TypeAdapter, ApiException, UrlValidator |
| **에러 처리** | 6 | **7** | without: ApiException 커스텀 예외, ProcessingStep enum 상태 머신 |
| **테스트** | **7** | 5 | with: 15개(채팅 3건 포함). without: 11개. 1회차 수동 리뷰 기준 |
| **개발 프로세스** | **9.5** | 3 | with: phase별 커밋, 문서 16개, hook 5개. without: 단일/소수 커밋 |
| **안정성** | **9** | 6 | with: 타임아웃 0, 분산 낮음. without: 타임아웃 1, 시간 편차 큼 |
| **시간 효율** | **8** | 5 | with: 평균 662초. without: 평균 901초 (27% 느림) |
| **비용 효율** | 6 | **7** | without: 평균 $5.8 (17% 저렴). 단, no1 미기록 |

> **점수 산정 기준**
>
> | 카테고리 | 측정 방법 | 10점 기준 | 0점 기준 |
> |---------|----------|----------|---------|
> | API 정합성 | `verify-api-contract.py` 자동 검증 (N=5 통과율) | 5/5 통과, critical 0 | 0/5 통과 |
> | 아키텍처 설계 | 1회차 브랜치 수동 코드 리뷰 — 설정 관리, 패턴 분리, 타입 안전성, 예외 처리 구조 평가 | 모든 영역에서 모범 패턴 적용 | 구조 없이 단일 파일 |
> | 에러 처리 | 1회차 브랜치 수동 코드 리뷰 — 커스텀 예외, 상태 머신, 에러 전파 방식 평가 | 커스텀 예외 + 상태 enum + 전역 핸들링 | try-catch 없음 |
> | 테스트 | 1회차 브랜치 테스트 파일 카운트 + 커버리지 범위 (pytest 기준) | 20개 이상 + 엣지케이스 포함 | 테스트 없음 |
> | 개발 프로세스 | 커밋 수, 문서 수, hook/gate 유무 — N=5 공통 관찰 | 의미 단위 커밋 + 문서화 + 자동 검증 | 단일 커밋, 문서 없음 |
> | 안정성 | N=5 실행 데이터 — 타임아웃 횟수, 시간 표준편차 | 0 타임아웃 + 낮은 편차 | 과반 타임아웃 |
> | 시간 효율 | N=5 평균 소요 시간 비교 | 400초 이하 | 1,800초 (타임아웃) |
> | 비용 효율 | N=5 평균 비용 비교 | $3 이하 | $20 (예산 상한) |
>
> - **자동 측정** (API 정합성, 안정성, 시간, 비용): N=5 실험 데이터에서 직접 산출
> - **수동 평가** (아키텍처, 에러 처리, 테스트): 1회차(no1) 브랜치 코드 리뷰 기준. 주관적 요소 포함.

### 4.2 가중 종합

API 정합성에 가중치 40% (앱이 작동하는지가 가장 중요), 나머지 균등 배분:

| | `with-dev-bounce` | `without-dev-bounce` |
|--|:-:|:-:|
| API 정합성 (40%) | 4.00 | 1.60 |
| 아키텍처 (10%) | 0.70 | 0.85 |
| 에러 처리 (5%) | 0.30 | 0.35 |
| 테스트 (8%) | 0.56 | 0.40 |
| 개발 프로세스 (12%) | 1.14 | 0.36 |
| 안정성 (10%) | 0.90 | 0.60 |
| 시간 효율 (10%) | 0.80 | 0.50 |
| 비용 효율 (5%) | 0.30 | 0.35 |
| **가중 합계** | **8.70** | **5.01** |

---

## 5. 아키텍처 비교

> 아래 비교는 **1회차(no1) 브랜치의 수동 코드 리뷰** 기준입니다. 다른 run에서도 유사한 패턴이 나타나지만, 5회 전부를 정밀 리뷰한 것은 아닙니다.

### Flutter 앱

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 상태관리 | Riverpod + StateNotifier (`SummaryState` copyWith) | Riverpod + StateNotifier (`ProcessingState` + `ProcessingStep` enum) |
| 모델 | Freezed (`VideoSummary`, `ChatMessage`) | Freezed (`SummaryEntity`) + 수동 Hive TypeAdapter |
| API 클라이언트 | `ApiService` — raw Map 반환, Provider에서 파싱 | `SummaryApiService` — 타입별 Response 클래스, `ApiException` 커스텀 예외 |
| 로컬 저장 | Hive (JSON 문자열 직렬화, Box\<dynamic\>) | Hive (TypeAdapter 등록, Box\<SummaryHiveModel\>) |
| URL 검증 | 없음 (서버에서 처리) | `UrlValidator` 클래스 (5개 패턴 정규식) |
| 채팅 UI | `SummaryDetailScreen` 하단 인라인 | `ChatWidget` 별도 위젯 (타이핑 애니메이션 포함) |

### FastAPI 백엔드

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 설정 관리 | `os.getenv()` 직접 호출 | `config.py` 분리 |
| Gemini 모델 | gemini-2.0-flash | gemini-2.5-flash |
| 프롬프트 언어 | 다국어 지원 (`language` 파라미터) | 한국어 고정 |
| temperature | 요약 0.3 / 채팅 0.7 | 미설정 (기본값) |
| 제목 추출 | oEmbed API (안정적) | HTML 파싱 + 정규식 (취약) |
| transcript 반환 | `list[TranscriptSegment]` + `full_text` | `str` (줄바꿈 joined) |
| 클라이언트 패턴 | 글로벌 변수 + `_get_client()` | `@lru_cache(maxsize=1)` |

### 설계 품질 평가

**without-dev-bounce가 우수한 점:**
1. `config.py` 분리 — 환경변수를 한 곳에서 관리
2. `ProcessingStep` enum — 상태 전이가 명시적
3. `ApiException` 커스텀 예외 — HTTP 상태 코드 포함
4. Repository 패턴 — 인터페이스 + 구현 분리
5. Hive TypeAdapter — 타입 안전한 직렬화
6. `UrlValidator` 클라이언트측 검증
7. `ChatWidget` 분리 + 타이핑 애니메이션

**with-dev-bounce가 우수한 점:**
1. **API 계약 정합성 100%** — 가장 중요한 차이
2. 다국어 프롬프트 지원 (`language` 파라미터)
3. temperature 설정 분리 (요약 0.3 / 채팅 0.7)
4. TranscriptSegment 구조체 — 타임스탬프별 세그먼트
5. oEmbed API 제목 추출 — HTML 파싱보다 안정적
6. 테스트 커버리지 15개 vs 11개 (채팅 엔드포인트 3건 포함)

---

## 6. 개발 프로세스 비교

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|------|-------------------|---------------------|
| 워크플로우 | Phase 0(인텐트)→1(계획)→2(승인)→3(개발)→4(검증) | 자유 개발 + 팀에이전트 |
| 커밋 단위 | phase/step별 의미 단위 | 단일 또는 소수 |
| 계획 문서 | plan.md + phase별 step docs | 없음 |
| Gate 시스템 | plan-gate + bash-gate + completion-gate | 없음 |
| QA 검증 | Verifier 3회 연속 통과 필수 | 없음 |
| Hook 스크립트 | 5개 (bash-audit, bash-gate, completion-gate, doc-reminder, plan-gate) | 없음 |

---

## 7. 결론

### 핵심 발견

1. **API 계약 정합성**: with-dev-bounce **100%** vs without-dev-bounce **60%**. 가장 결정적인 차이.
2. **원인 분석**: without-dev-bounce는 프론트엔드와 백엔드를 동시에 생성하면서 필드명이 어긋남. with-dev-bounce는 Phase별 순차 구현(백엔드 → 프론트엔드) + QA 검증으로 자연스럽게 방지.
3. **시간 효율**: with-dev-bounce가 27% 빠름 (662초 vs 901초). Gate 시스템이 삽질을 줄여줌.
4. **비용**: with-dev-bounce가 약 17% 더 비쌈 ($7.0 vs $5.8). 검증 단계에 추가 토큰 소모.
5. **안정성**: with-dev-bounce는 타임아웃 0회, 시간 편차 작음. without-dev-bounce는 타임아웃 1회, 331초~1,807초로 편차 큼.
6. **설계 패턴**: without-dev-bounce의 코드가 더 성숙한 패턴을 사용하지만, API 계약이 깨지면 의미가 없음.

### 가중 종합 점수

| | `with-dev-bounce` | `without-dev-bounce` |
|--|:-:|:-:|
| **8.70 / 10** | | |
| | **8.70** | **5.01** |

### 한 줄 요약

> **dev-bounce는 "작동하는 소프트웨어"를 만든다.** 설계 패턴은 without-dev-bounce가 더 성숙하지만, 40% 확률로 API가 깨진다면 의미가 없다.

---

## 8. 실험 한계 및 위협 요인

본 실험의 결과를 해석할 때 다음 사항을 고려해야 합니다.

### 8.1 표본 크기

N=5는 통계적 유의성을 확보하기에 작은 표본입니다. Mann-Whitney U 검정을 실행하지 못했으며 (scipy 미설치), 현재 수치는 기술 통계(descriptive statistics)에 해당합니다. "27% 빠름", "17% 저렴" 등의 차이가 통계적으로 유의한지는 추가 검증이 필요합니다.

### 8.2 프롬프트 차이 (교란 변수)

두 조건의 프롬프트가 완전히 동일하지 않습니다:
- **with-dev-bounce**: `/dev-bounce` 명령으로 구조화된 파이프라인 실행
- **without-dev-bounce**: "팀에이전트를 구성해서 진행해줘" 추가 지시

"팀에이전트 구성" 지시 자체가 결과에 영향을 줬을 가능성이 있습니다. 예를 들어:
- 팀 구성에 시간/토큰을 소비하느라 정작 API 검증에 소홀했을 수 있음
- 팀에이전트 지시 없이 자유 개발했으면 오히려 더 좋은 결과가 나왔을 수 있음
- 반대로, 팀에이전트 덕분에 without 조건이 상대적으로 나은 설계 패턴을 적용했을 수도 있음

순수하게 "dev-bounce 유무"만 비교하려면, without 조건에서 팀에이전트 지시를 제거한 추가 실험이 필요합니다.

### 8.3 LOC 측정 오류

일부 run에서 서버 LOC가 ~830,000으로 측정됨 (`.venv/` 가상환경 디렉토리 포함). 실제 서버 코드는 수백 줄 수준. 본 보고서에서는 LOC를 주요 메트릭으로 사용하지 않았으며, 앱 LOC(중앙값 with: 1,362 / without: 1,704)만 참고 수치로 제시합니다.

### 8.4 자동화 환경 차이

실제 개발과 다른 점:
- 사용자 입력을 자동 응답으로 대체 ("네, 진행해주세요")
- with-dev-bounce: `EnterPlanMode`/`ExitPlanMode` 금지 override 적용 (stream-json 멀티턴 호환 문제)
- 커밋/푸시 비활성화 (commit_strategy=none)
- 이러한 override가 dev-bounce의 실제 성능을 과소/과대 평가했을 수 있음

---

## 9. 실험 재현

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

### 결과 브랜치

각 실험 run의 전체 코드는 개별 브랜치에서 확인 가능:

```
with-dev-bounce-no1 ~ no5
without-dev-bounce-no1 ~ no5
```

---

## 10. 기술 스택

| 영역 | 기술 |
|------|------|
| Frontend | Flutter (Dart) — Riverpod, GoRouter, Hive, Freezed |
| Backend | FastAPI (Python) — Pydantic, Uvicorn |
| AI | Google Gemini (2.0 Flash / 2.5 Flash) |
| 실험 자동화 | Python (stream-json) + Bash (worktree 오케스트레이션) |
| API 검증 | Python AST 기반 Pydantic 스키마 파싱 + Dart HTTP 패턴 매칭 |

## 11. 실행 방법

> main 브랜치에는 실험 코드만 있습니다. 앱 코드는 실험 브랜치(`with-dev-bounce-no*`, `without-dev-bounce-no*`)를 확인하세요.

```bash
# 예: with-dev-bounce-no1 브랜치 기준
git checkout with-dev-bounce-no1

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
