# 전수조사 상세 보고서 — with-dev-bounce vs without-dev-bounce

> 분석일: 2026-03-08
> 방법: git show로 두 브랜치의 모든 .dart/.py 파일을 1줄 단위로 읽고 교차 대조

---

## 1. API 계약 전수조사 — `with-dev-bounce`

### `/transcript` (POST)

**Dart → Python 요청:**
```
Dart (api_service.dart L16):   jsonEncode({'url': url})
Python (schemas.py L4-5):      class TranscriptRequest: url: str
→ ✅ 일치
```

**Python → Dart 응답:**
```
Python (schemas.py L14-18):
  TranscriptResponse:
    video_id: str
    title: str
    transcript: list[TranscriptSegment]  # [{text, start, duration}]
    full_text: str

Dart (summary_provider.dart L72-82):
  transcriptData['video_id'] as String    → ✅ 일치
  transcriptData['title'] as String       → ✅ 일치
  transcriptData['full_text'] as String   → ✅ 일치
  transcriptData['transcript'] as List    → ✅ 일치 (세그먼트 리스트)
```

### `/summarize` (POST)

**Dart → Python 요청:**
```
Dart (api_service.dart L35-39):
  jsonEncode({
    'video_id': videoId,
    'title': title,
    'full_text': fullText,
    'language': language,
  })

Python (schemas.py L21-25):
  SummarizeRequest:
    video_id: str
    title: str
    full_text: str
    language: str = "ko"

→ ✅ 4/4 필드 일치
```

**Python → Dart 응답:**
```
Python (schemas.py L28-30):   SummarizeResponse: video_id, summary
Dart (api_service.dart L43):  ['summary'] as String
→ ✅ 일치
```

### `/chat` (POST)

**Dart → Python 요청:**
```
Dart (api_service.dart L62-67):
  jsonEncode({
    'video_id': videoId,
    'title': title,
    'full_text': fullText,
    'messages': messages.map((m) => m.toJson()).toList(),
    'language': language,
  })

Python (schemas.py L38-43):
  ChatRequest:
    video_id: str
    title: str
    full_text: str
    messages: list[ChatMessage]
    language: str = "ko"

→ ✅ 5/5 필드 일치
```

**ChatMessage 구조:**
```
Dart (chat_message.dart):     role: String, content: String
Python (schemas.py L33-35):   role: str, content: str
→ ✅ 일치
```

**Python → Dart 응답:**
```
Python (schemas.py L46-48):   ChatResponse: video_id, reply
Dart (api_service.dart L71):  ['reply'] as String
→ ✅ 일치
```

**총 검증 필드 20개, 불일치 0건.**

---

## 2. API 계약 전수조사 — `without-dev-bounce`

### `/transcript` (POST)

**Dart → Python 요청:**
```
Dart (summary_api_service.dart L70):  jsonEncode({'url': url})
Python (schemas.py L4-5):             TranscriptRequest: url: str
→ ✅ 일치
```

**Python → Dart 응답:**
```
Python (schemas.py L8-13):
  TranscriptResponse:
    video_id: str
    title: str          ← Python 필드명
    transcript: str
    thumbnail_url: str
    source: str

Dart (summary_api_service.dart L19-23):
  TranscriptResponse.fromJson:
    transcript: json['transcript']     → ✅
    videoTitle: json['video_title']    → ❌ Python은 'title'
    videoId: json['video_id']          → ✅
```

**❌ B1: Dart는 `video_title` 기대, Python은 `title` 반환 → null → `as String` 크래시**

### `/summarize` (POST)

**Dart → Python 요청:**
```
Dart (summary_api_service.dart L83):
  jsonEncode({'transcript': transcript})

Python (schemas.py L16-18):
  SummarizeRequest:
    transcript: str
    video_title: str    ← 필수!
```

**❌ B2: Dart가 `video_title`을 전송하지 않음 → 422 Validation Error**

**Python → Dart 응답:**
```
Python (schemas.py L21-22):  SummarizeResponse: summary
Dart (L36):                  json['summary'] as String
→ ✅ 일치 (요청이 통과한다면)
```

### `/chat` (POST)

**Dart → Python 요청:**
```
Dart (summary_api_service.dart L106-112):
  jsonEncode({
    'question': question,        ← Python은 'message'
    'transcript': transcript,    ✅
    'summary': summary,          ✅
    'history': ?history,         ← 유효하지 않은 Dart 문법
  })
  (video_title 미전송)

Python (schemas.py L30-35):
  ChatRequest:
    transcript: str
    summary: str
    video_title: str    ← 필수, 미전송
    message: str        ← Dart는 'question'으로 전송
    history: list[ChatMessage] = []
```

**❌ B3: `question` vs `message` 필드명 불일치**
**❌ B4: `video_title` 필수 필드 미전송**
**❌ B6: `?history` — 유효하지 않은 Dart 문법 (컴파일 에러)**

**Python → Dart 응답:**
```
Python (schemas.py L38-39):  ChatResponse: reply
Dart (L44):                  json['answer'] as String
```

**❌ B5: `answer` vs `reply` 필드명 불일치**

**총 검증 필드 16개, 불일치 5건 + 문법 오류 1건.**

---

## 3. Python 내부 호출 검증

### `with-dev-bounce`

```python
# api_v1.py L44
summarize_transcript(request.title, request.full_text, request.language)
# gemini_service.py L17
def summarize_transcript(title: str, full_text: str, language: str = "ko") -> str:
→ ✅ 순서·타입 일치

# api_v1.py L53
chat_about_video(request.title, request.full_text, messages, request.language)
# gemini_service.py L42
def chat_about_video(title: str, full_text: str, messages: list[dict], language: str = "ko") -> str:
→ ✅ 순서·타입 일치

# api_v1.py L33
segments, full_text = get_transcript(video_id)
# transcript_service.py L42
def get_transcript(video_id: str) -> tuple[list[dict], str]:
→ ✅ 반환 타입 일치 (list[dict], str)
```

### `without-dev-bounce`

```python
# api_v1.py L46
gemini_service.summarize_transcript(req.transcript, req.video_title)
# gemini_service.py L44
def summarize_transcript(transcript: str, video_title: str) -> str:
→ ✅ 순서·타입 일치

# api_v1.py L54-59
gemini_service.chat(
    transcript=req.transcript, summary=req.summary,
    video_title=req.video_title, message=req.message,
    history=[m.model_dump() for m in req.history],
)
# gemini_service.py L50
def chat(transcript, summary, video_title, message, history):
→ ✅ 키워드 인자 일치

# api_v1.py L35
text, source = transcript_service.get_transcript(video_id)
# transcript_service.py L39
def get_transcript(video_id: str) -> tuple[str, str]:
→ ✅ 반환 타입 일치 (str, str)
```

**두 브랜치 모두 Python 내부 호출은 완벽히 정상.**

---

## 4. 파일별 라인 수 비교

### `with-dev-bounce` (generated 제외)

| 파일 | 줄 수 |
|------|:----:|
| app/lib/main.dart | 23 |
| app/lib/app.dart | 25 |
| app/lib/core/constants/api_constants.dart | 8 |
| app/lib/core/theme/app_theme.dart | 50 |
| app/lib/features/summarize/domain/entities/video_summary.dart | 32 |
| app/lib/features/summarize/domain/entities/chat_message.dart | 15 |
| app/lib/features/summarize/infrastructure/api_service.dart | 73 |
| app/lib/features/summarize/infrastructure/storage_service.dart | 46 |
| app/lib/features/summarize/application/summary_provider.dart | 145 |
| app/lib/features/summarize/application/settings_provider.dart | 33 |
| app/lib/features/summarize/application/history_provider.dart | 32 |
| app/lib/features/summarize/presentation/home_screen.dart | 139 |
| app/lib/features/summarize/presentation/summary_detail_screen.dart | 283 |
| app/lib/features/summarize/presentation/widgets/loading_progress.dart | 70 |
| app/lib/features/summarize/presentation/widgets/video_result_card.dart | 101 |
| app/lib/features/history/presentation/history_screen.dart | 204 |
| app/lib/features/settings/presentation/settings_screen.dart | 145 |
| app/lib/routing/app_router.dart | 53 |
| app/lib/routing/shell_scaffold.dart | 54 |
| server/main.py | 28 |
| server/models/schemas.py | 52 |
| server/services/transcript_service.py | 52 |
| server/services/gemini_service.py | 70 |
| server/routers/api_v1.py | 59 |
| server/tests/conftest.py | 14 |
| server/tests/test_transcript.py | 72 |
| server/tests/test_summarize.py | 99 |
| **합계** | **1,984** |

### `without-dev-bounce` (generated 제외)

| 파일 | 줄 수 |
|------|:----:|
| app/lib/main.dart | 42 |
| app/lib/app.dart | 25 |
| app/lib/core/constants/api_constants.dart | 16 |
| app/lib/core/constants/hive_constants.dart | 6 |
| app/lib/core/theme/app_theme.dart | 138 |
| app/lib/core/utils/url_validator.dart | 26 |
| app/lib/features/summary/domain/entities/summary_entity.dart | 21 |
| app/lib/features/summary/domain/repositories/summary_repository.dart | 9 |
| app/lib/features/summary/infrastructure/summary_api_service.dart | 136 |
| app/lib/features/summary/infrastructure/summary_hive_model.dart | 106 |
| app/lib/features/summary/infrastructure/summary_repository_impl.dart | 40 |
| app/lib/features/summary/application/summary_notifier.dart | 139 |
| app/lib/features/summary/application/summary_providers.dart | 19 |
| app/lib/features/summary/presentation/home_screen.dart | 248 |
| app/lib/features/summary/presentation/summary_detail_screen.dart | 345 |
| app/lib/features/summary/presentation/widgets/chat_widget.dart | 300 |
| app/lib/features/history/application/history_notifier.dart | 30 |
| app/lib/features/history/application/history_providers.dart | 9 |
| app/lib/features/history/presentation/history_screen.dart | 248 |
| app/lib/features/settings/presentation/settings_screen.dart | 179 |
| app/lib/routing/app_router.dart | 116 |
| server/main.py | 22 |
| server/config.py | 14 |
| server/models/schemas.py | 39 |
| server/services/transcript_service.py | 44 |
| server/services/gemini_service.py | 68 |
| server/routers/api_v1.py | 64 |
| server/tests/conftest.py | 9 |
| server/tests/test_transcript.py | 42 |
| server/tests/test_summarize.py | 29 |
| **합계** | **2,543** |

---

## 5. 커밋 이력

### `with-dev-bounce` (main 분기 이후 12커밋)

```
40a5fdb chore: Xcode 프로젝트 파일 자동 업데이트
c0205ed fix: 로컬 서버 연결을 위한 iOS ATS 허용 및 서버 URL 변경
9c3ba77 fix: Hive 초기화 에러 핸들링 추가
8107692 chore: iOS 빌드 설정 업데이트 (signing + Podfile.lock)
c4d2c84 chore: dev-bounce 워크플로우 완료 상태 업데이트
e22c645 feat: Flutter 기능 완성 - 히스토리/설정 화면 + 네비게이션 연결
f416d42 docs: Phase 3 Flutter 기반 구축 완료 + Phase 4 계획 추가
6d6fec3 feat: Freezed 모델 코드 생성 + provider/위젯 개선
a894065 feat: 배포 스크립트 + systemd 서비스 파일 추가
ce40bdc feat: Flutter 앱 기반 구축 + dev-bounce 워크플로우 설정
6ffffce feat: Gemini AI 요약/채팅 서비스 + summarize/chat 엔드포인트 구현
4426a3d feat: FastAPI 서버 기반 구축 + 트랜스크립트 엔드포인트 구현
```

### `without-dev-bounce` (전체 이력 1커밋)

```
78d7a70 feat: Flutter 앱 + FastAPI 백엔드 초기 구현
```

---

## 6. 배포 스크립트 비교

### `with-dev-bounce` (deploy.sh, 39줄)

```bash
1. 로컬 pytest 실행           # 배포 전 테스트
2. ssh: systemctl stop        # 서비스 중단
3. rsync: 서버 파일 동기화      # .env, venv, __pycache__ 제외
4. ssh: pip install           # 의존성 설치
5. ssh: pytest 실행            # 원격 테스트 (배포 후 검증)
6. ssh: systemctl start       # 서비스 재시작 + 로그 확인
```

### `without-dev-bounce` (deploy.sh, 21줄)

```bash
1. rsync: 서버 파일 동기화
2. ssh: pip install + systemctl restart + status 확인
```

**차이**: `with-dev-bounce`는 배포 전 로컬 테스트 + 배포 후 원격 테스트의 이중 검증.

---

## 7. dev-bounce 인프라 상세

`with-dev-bounce`에만 존재하는 파일:

### 에이전트 정의 (8개)

```
.claude/agents/intent.md         # 사용자 의도 파악
.claude/agents/planner-lead.md   # 리드 플래너
.claude/agents/planner-dev.md    # 개발 플래너
.claude/agents/planner-qa.md     # QA 플래너
.claude/agents/dev.md            # 개발 실행
.claude/agents/qa.md             # QA 테스트
.claude/agents/verifier.md       # 최종 검증
.claude/agents/lead.md           # 리드 총괄
```

### Hook 스크립트 (5개)

```
.claude/hooks/bash-audit.sh      # bash 명령 감사
.claude/hooks/bash-gate.sh       # bash 실행 게이트
.claude/hooks/completion-gate.sh # 완료 조건 검증
.claude/hooks/doc-reminder.sh    # 문서 작성 알림
.claude/hooks/plan-gate.sh       # 계획 승인 게이트
```

### Phase 문서 (16개)

```
Phase 1: backend-foundation (2 steps)
Phase 2: backend-ai-deploy (2 steps)
Phase 3: flutter-foundation (3 steps)
Phase 4: flutter-features (3 steps)
```

---

## 8. 이 보고서에서 의도적으로 제외한 것

이전 보고서에서 `without-dev-bounce` 전용 Critical 버그로 보고된 3건은 **이번 전수조사에서도 오탐으로 확인**되어 포함하지 않음:

1. ~~`summarize_transcript()` 파라미터 순서 역전~~ — 실제 코드: `summarize_transcript(req.transcript, req.video_title)` → `def summarize_transcript(transcript: str, video_title: str)` ✅ 순서 정상
2. ~~`gemini_service.chat()` 함수 미존재~~ — 실제 코드: `gemini_service.py` L50에 `def chat(...)` 존재 ✅
3. ~~`get_transcript()` 반환 타입 불일치~~ — 실제 코드: `tuple[str, str]` 반환, 라우터에서 `text, source = ...`로 수신 ✅
