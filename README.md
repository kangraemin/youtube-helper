# YouTube Helper — dev-bounce A/B 실험 보고서

> AI 코딩 에이전트에 **구조화된 워크플로우(dev-bounce)**를 적용하면 품질이 달라질까?
> 동일한 앱을 10번 만들어 보고, 숫자로 답한다.

<br>

## TL;DR

|  | with-dev-bounce | without-dev-bounce |
|--|:-:|:-:|
| **API 계약 통과율** | **100%** (5/5) | **60%** (3/5) |
| **가중 종합 점수** | **8.27** / 10 | **5.53** / 10 |
| 평균 소요 시간 | 662초 (11분) | 901초 (15분) |
| 평균 비용 | $7.0 | $5.8 |

> **한 줄 요약** — dev-bounce는 "작동하는 소프트웨어"를 만든다. 설계 패턴은 without이 더 성숙하지만, 40% 확률로 API가 깨진다면 의미가 없다.

---

<br>

## 1. 실험 설계

동일한 요구사항(YouTube 자막 추출 → AI 요약 → 채팅)을, 독립된 git worktree에서 **매번 처음부터** 구현.

| 항목 | `with-dev-bounce` | `without-dev-bounce` |
|:-----|:------------------:|:---------------------:|
| 개발 방식 | dev-bounce 파이프라인 | 자유 개발 + 팀에이전트 |
| 반복 횟수 | 5회 | 5회 |
| 시작점 | `f8e094a` (빈 레포) | `f8e094a` (빈 레포) |
| 기술 스택 | Flutter + FastAPI + Gemini | Flutter + FastAPI + Gemini |
| 타임아웃 | 30분 | 30분 |
| 예산 | $20 / run | $20 / run |

<details>
<summary><b>자동화 파이프라인 상세</b></summary>

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

- **실험 기간**: 2026-03-08 ~ 09
- **자동화**: `experiment/run-claude.py` (stream-json) + `experiment/experiment-runner.sh`
- **검증**: `experiment/verify-api-contract.py` (Dart ↔ Python API 계약 자동 검증)

</details>

---

<br>

## 2. 핵심 결과 — API 계약 정합성

> **가장 중요한 질문**: Dart 프론트엔드가 Python 백엔드 API 스키마와 일치하는가?

| | `with-dev-bounce` | `without-dev-bounce` |
|:--|:-:|:-:|
| **API 계약 통과** | **5/5 (100%)** | **3/5 (60%)** |
| Critical 불일치 | 0건 | 2건 (no2, no5) |
| Warning | 0건 | 1건 (no3) |
| 서버 실행 가능 | 5/5 | 5/5 |

### Run별 결과

| Run | with | without |
|:---:|:----:|:-------:|
| 1 | ✅ | ✅ |
| 2 | ✅ | ❌ 1 critical |
| 3 | ✅ | ⚠️ 1 warning |
| 4 | ✅ | ✅ |
| 5 | ✅ | ❌ 1 critical |

### 왜 깨지는가?

without-dev-bounce에서 발생한 불일치는 전형적인 **크로스 언어 계약 불일치**:

| 유형 | 예시 |
|------|------|
| 필드명 불일치 | Dart `video_title` → Python `title` |
| 응답 키 불일치 | Dart `json['answer']` → Python `reply` |
| 필수 필드 누락 | Dart 미전송 → Python `ValidationError` |

**원인**: 프론트엔드와 백엔드를 동시에 생성하면서 필드명이 어긋남.
**with-dev-bounce는 왜 안 깨지나**: Phase별 순차 구현(백엔드 먼저 → 프론트가 스키마에 맞춤) + QA 검증.

---

<br>

## 3. 시간 · 비용 · 안정성

| | `with-dev-bounce` | `without-dev-bounce` |
|:--|:-:|:-:|
| **평균 시간** | **662초** (11분) | **901초** (15분) |
| **평균 비용** | $7.0 | $5.8* |
| 타임아웃 | 0회 | 1회 |
| 시간 범위 | 379 ~ 883초 | 331 ~ 1,807초 |

> \* without no1은 타임아웃으로 비용 미기록. 평균은 4회 기준이므로 실제로는 더 높을 수 있음.

### 개별 실행 데이터

<details>
<summary><b>컬럼 설명</b></summary>

| 컬럼 | 의미 |
|------|------|
| **시간** | Claude가 작업 완료까지 걸린 총 시간 (초) |
| **비용** | Claude API 토큰 사용 비용 (USD) |
| **Auto-respond** | 자동화 스크립트가 "진행해주세요", "승인합니다" 등을 보낸 횟수 |
| **API** | `verify-api-contract.py`로 Dart ↔ Python 필드명 자동 교차 검증 결과 |

</details>

#### with-dev-bounce

| Run | 시간 | 비용 | Auto-respond | API |
|:---:|:----:|:----:|:------------:|:---:|
| 1 | 883초 | $17.02 | 15회 | ✅ |
| 2 | 379초 | $3.73 | 31회 | ✅ |
| 3 | 851초 | $5.18 | 2회 | ✅ |
| 4 | 629초 | $5.11 | 13회 | ✅ |
| 5 | 569초 | $3.91 | 2회 | ✅ |
| **avg** | **662초** | **$6.99** | **12.6회** | **5/5** |

#### without-dev-bounce

| Run | 시간 | 비용 | Auto-respond | API |
|:---:|:----:|:----:|:------------:|:---:|
| 1 | 1,807초 | — | 0회 | ✅ |
| 2 | 882초 | $6.35 | 2회 | ❌ |
| 3 | 331초 | $2.85 | 40회 | ⚠️ |
| 4 | 709초 | $3.90 | 2회 | ✅ |
| 5 | 775초 | $10.20 | 17회 | ❌ |
| **avg** | **901초** | **$5.83** | **12.2회** | **3/5** |

---

<br>

## 4. 종합 점수표

> 1회차(no1) 수동 코드 리뷰 + N=5 자동 측정 기반. 수동 평가 항목은 주관적 요소 포함.

### 4.1 프론트엔드 (Flutter / Dart)

| 카테고리 | with | without | 근거 |
|:---------|:----:|:-------:|:-----|
| API 정합성 | **10** | 4 | 5/5 통과 vs 3/5, Dart→Python 필드 불일치 2건 |
| 아키텍처 | 7 | **8.5** | Repository 패턴, TypeAdapter, ProcessingStep enum, UrlValidator |
| 에러 처리 | 6 | **7.5** | `ApiException`(HTTP 상태 코드), `ProcessingStep.error` 상태 머신 |
| UI 완성도 | 7 | **7.5** | `ChatWidget` 분리 + 타이핑 애니메이션, 3탭 |
| **소계** | **7.5** | **6.9** | API 정합성 가중 50% |

### 4.2 백엔드 (FastAPI / Python)

| 카테고리 | with | without | 근거 |
|:---------|:----:|:-------:|:-----|
| 설정 관리 | 5 | **8** | `config.py` 분리 vs `os.getenv()` 산재 |
| API 설계 | **8** | 6 | `TranscriptSegment` 구조체, 다국어 `language` 파라미터 |
| AI / 프롬프트 | **8** | 5 | temperature 분리(0.3 / 0.7), 다국어 프롬프트 |
| 외부 연동 | **8** | 5 | oEmbed API(안정) vs HTML 파싱(취약) |
| 클라이언트 패턴 | 6 | **7** | `@lru_cache` vs 글로벌 변수 |
| 테스트 | **7** | 5 | 15개(채팅 3건 포함) vs 11개 |
| **소계** | **7.0** | **6.0** | 균등 배분 |

### 4.3 공통 메트릭

| 카테고리 | with | without | 근거 |
|:---------|:----:|:-------:|:-----|
| 개발 프로세스 | **9.5** | 3 | phase별 커밋·문서 16개·hook 5개 vs 단일 커밋 |
| 안정성 | **9** | 6 | 타임아웃 0·편차 작음 vs 타임아웃 1·편차 큼 |
| 시간 효율 | **8** | 5 | 662초 vs 901초 (27% 느림) |
| 비용 효율 | 6 | **7** | $5.8 vs $7.0 (17% 저렴) |
| **소계** | **8.1** | **5.3** | 균등 배분 |

### 4.4 가중 종합

| 영역 | 가중치 | with | without |
|:-----|:------:|:----:|:-------:|
| 프론트엔드 | 30% | 2.25 | 2.07 |
| 백엔드 | 20% | 1.40 | 1.20 |
| API 정합성 | 30% | 3.00 | 1.20 |
| 공통 메트릭 | 20% | 1.62 | 1.06 |
| **합계** | **100%** | **8.27** | **5.53** |

> **가중치 설계**: API 정합성(30%)을 별도 최대 가중 — "앱이 작동하는가"가 가장 중요. 프론트(30%) > 백엔드(20%)는 UX 직결 영역 우선.

<details>
<summary><b>점수 산정 기준 상세</b></summary>

| 구분 | 측정 방법 | 10점 | 0점 |
|:-----|:---------|:-----|:----|
| API 정합성 | `verify-api-contract.py` 자동 검증 (N=5) | 5/5 통과 | 0/5 통과 |
| 프론트 아키텍처 | 수동 리뷰 — 패턴 분리, 타입 안전성, 상태 관리 | 모든 영역 모범 패턴 | 단일 파일 |
| 백엔드 설계 | 수동 리뷰 — 설정, API, 외부 연동, 테스트 | 각 영역 모범 사례 | 하드코딩 |
| 개발 프로세스 | 커밋 수, 문서, hook/gate 유무 (N=5) | 의미 단위 커밋 + 문서 + 자동 검증 | 단일 커밋 |
| 안정성 | 타임아웃 횟수 + 시간 표준편차 (N=5) | 0 타임아웃 + 낮은 편차 | 과반 타임아웃 |
| 시간 / 비용 | N=5 평균 비교 | 400초 / $3 이하 | 1,800초 / $20 |

- **자동 측정**: API 정합성, 안정성, 시간, 비용
- **수동 평가**: 아키텍처, 에러 처리, UI, API 설계 — 1회차(no1) 코드 리뷰 기준

</details>

---

<br>

## 5. 아키텍처 상세 비교

> 1회차(no1) 브랜치 수동 코드 리뷰 기준. 다른 run에서도 유사한 패턴이 나타나지만 5회 전부를 정밀 리뷰하진 않았습니다.

<details>
<summary><b>Flutter 앱 비교</b></summary>

| 항목 | with-dev-bounce | without-dev-bounce |
|:-----|:----------------|:-------------------|
| 상태관리 | Riverpod + StateNotifier (`SummaryState`) | Riverpod + StateNotifier (`ProcessingStep` enum) |
| 모델 | Freezed (`VideoSummary`, `ChatMessage`) | Freezed + Hive TypeAdapter |
| API 클라이언트 | raw Map → Provider 파싱 | 타입별 Response + `ApiException` |
| 로컬 저장 | Hive (JSON 문자열) | Hive (TypeAdapter) |
| URL 검증 | 서버 의존 | 클라이언트 `UrlValidator` |
| 채팅 UI | 인라인 (2탭) | `ChatWidget` 분리 + 타이핑 애니메이션 (3탭) |

</details>

<details>
<summary><b>FastAPI 백엔드 비교</b></summary>

| 항목 | with-dev-bounce | without-dev-bounce |
|:-----|:----------------|:-------------------|
| 설정 관리 | `os.getenv()` 직접 | `config.py` 분리 |
| Gemini 모델 | gemini-2.0-flash | gemini-2.5-flash |
| 프롬프트 언어 | 다국어 (`language` 파라미터) | 한국어 고정 |
| temperature | 요약 0.3 / 채팅 0.7 | 미설정 (기본값) |
| 제목 추출 | oEmbed API (안정적) | HTML 파싱 + 정규식 (취약) |
| transcript | `list[TranscriptSegment]` + `full_text` | `str` (줄바꿈 joined) |
| 클라이언트 | 글로벌 변수 + `_get_client()` | `@lru_cache(maxsize=1)` |

</details>

<details>
<summary><b>각 방식의 장점 요약</b></summary>

**without-dev-bounce가 우수한 점:**
1. `config.py` — 환경변수 한 곳 관리
2. `ProcessingStep` enum — 명시적 상태 전이
3. `ApiException` — HTTP 상태 코드 포함 커스텀 예외
4. Repository 패턴 — 인터페이스 + 구현 분리
5. Hive TypeAdapter — 타입 안전 직렬화
6. `UrlValidator` — 클라이언트 사전 검증
7. `ChatWidget` — 분리 + 타이핑 애니메이션

**with-dev-bounce가 우수한 점:**
1. **API 계약 100% 정합** — 가장 중요한 차이
2. 다국어 프롬프트 (`language` 파라미터)
3. temperature 튜닝 (요약 0.3 / 채팅 0.7)
4. `TranscriptSegment` — 타임스탬프별 세그먼트
5. oEmbed API — HTML 파싱보다 안정적
6. 테스트 15개 vs 11개 (채팅 엔드포인트 3건)

</details>

---

<br>

## 6. 개발 프로세스 비교

| 항목 | with-dev-bounce | without-dev-bounce |
|:-----|:---------------:|:-------------------:|
| 워크플로우 | Phase 0→1→2→3→4 | 자유 개발 + 팀에이전트 |
| 커밋 | phase/step 단위 | 단일 / 소수 |
| 계획 문서 | plan.md + step docs | 없음 |
| Gate 시스템 | plan + bash + completion | 없음 |
| QA 검증 | Verifier 3회 연속 통과 | 없음 |
| Hook | 5개 | 없음 |

---

<br>

## 7. 결론

### 핵심 발견

| # | 발견 | 상세 |
|:-:|:-----|:-----|
| 1 | **API 정합성이 가장 큰 차이** | with 100% vs without 60% |
| 2 | **원인: 동시 생성 vs 순차 구현** | 프론트·백을 한번에 만들면 필드명이 어긋남. Phase별 순차 구현 + QA가 방지. |
| 3 | **with가 27% 빠름** | 662초 vs 901초. Gate 시스템이 삽질을 줄여줌. |
| 4 | **with가 17% 비쌈** | $7.0 vs $5.8. 검증 단계에 토큰 추가 소모. |
| 5 | **with가 더 안정적** | 타임아웃 0회, 시간 편차 작음. without은 331~1,807초. |
| 6 | **without 설계가 더 성숙** | 하지만 API가 깨지면 의미 없음. |

### 가중 종합

| | with-dev-bounce | without-dev-bounce |
|:--|:-:|:-:|
| **총점** | **8.27 / 10** | **5.53 / 10** |
| 프론트엔드 (30%) | 2.25 | 2.07 |
| 백엔드 (20%) | 1.40 | 1.20 |
| API 정합성 (30%) | 3.00 | 1.20 |
| 공통 메트릭 (20%) | 1.62 | 1.06 |

---

<br>

## 8. 실험 한계

<details>
<summary><b>8.1 표본 크기</b></summary>

N=5는 통계적 유의성을 확보하기에 작은 표본. Mann-Whitney U 검정 미실행 (scipy 미설치). "27% 빠름", "17% 저렴" 등이 통계적으로 유의한지는 추가 검증 필요.

</details>

<details>
<summary><b>8.2 프롬프트 차이 (교란 변수)</b></summary>

두 조건의 프롬프트가 동일하지 않음:
- **with**: `/dev-bounce` 명령 → 구조화된 파이프라인
- **without**: "팀에이전트를 구성해서 진행해줘" 추가 지시

"팀에이전트 구성" 지시 자체가 결과에 영향을 줬을 가능성:
- 팀 구성에 시간/토큰을 소비 → API 검증 소홀
- 팀에이전트 없이 자유 개발했으면 더 나았을 수도 있음
- 반대로 팀에이전트 덕분에 설계 패턴이 성숙했을 수도 있음

순수 비교를 위해선 팀에이전트 지시를 제거한 추가 실험이 필요.

</details>

<details>
<summary><b>8.3 LOC 측정 오류</b></summary>

일부 run에서 서버 LOC가 ~830,000으로 측정됨 (`.venv/` 포함). 실제 서버 코드는 수백 줄. 본 보고서에서는 LOC를 주요 메트릭으로 사용하지 않음.

</details>

<details>
<summary><b>8.4 자동화 환경 차이</b></summary>

실제 개발과 다른 점:
- 사용자 입력을 자동 응답으로 대체
- with: `EnterPlanMode`/`ExitPlanMode` 금지 override (stream-json 호환 문제)
- 커밋/푸시 비활성화 (`commit_strategy=none`)
- 이러한 override가 dev-bounce 성능을 과소/과대 평가했을 수 있음

</details>

---

<br>

## 9. 실험 재현

```bash
# 전체 실행 (with + without 각 5회)
./experiment/experiment-runner.sh

# 특정 모드만
./experiment/experiment-runner.sh --mode with --start 1 --end 5

# 드라이런
./experiment/experiment-runner.sh --dry-run

# 결과 재집계
python3 experiment/aggregate-results.py --results-dir experiment/results
```

<details>
<summary><b>설정 변경</b></summary>

```bash
# experiment/config.env
NUM_RUNS=10          # 반복 횟수
CLAUDE_TIMEOUT=1800  # 타임아웃 (초)
INITIAL_COMMIT=f8e094a  # 시작 커밋
```

</details>

### 결과 브랜치

각 run의 전체 코드는 개별 브랜치에서 확인 가능:

```
with-dev-bounce-no1 ~ no5
without-dev-bounce-no1 ~ no5
```

---

<br>

## 10. 기술 스택

| 영역 | 기술 |
|:-----|:-----|
| Frontend | Flutter (Dart) — Riverpod, GoRouter, Hive, Freezed |
| Backend | FastAPI (Python) — Pydantic, Uvicorn |
| AI | Google Gemini (2.0 Flash / 2.5 Flash) |
| 실험 자동화 | Python (stream-json) + Bash (worktree) |
| API 검증 | Python AST 기반 스키마 파싱 + Dart HTTP 패턴 매칭 |

## 11. 실행 방법

> main 브랜치에는 실험 코드만 있습니다. 앱 코드는 실험 브랜치를 확인하세요.

```bash
git checkout with-dev-bounce-no1  # 예시

# 서버
cd server && python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
echo "GEMINI_API_KEY=your-key" > .env
python main.py

# 앱
cd app && flutter pub get && flutter run
```
