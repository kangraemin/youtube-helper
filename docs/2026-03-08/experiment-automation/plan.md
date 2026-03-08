# Experiment Automation: dev-bounce A/B 반복 비교 시스템

## Context

dev-bounce vs without-dev-bounce 워크플로우를 1회만 비교한 상태. 통계적 유의성을 위해 N=10 반복 실험을 자동화하는 스크립트를 구현한다.

## 핵심 결정사항

- **실행 방식**: `claude` interactive + Python pexpect 자동 입력 (hook 동작 보장)
- **with-dev-bounce 설정**: 빈 레포 + `bash <(curl -sL https://raw.githubusercontent.com/kangraemin/ai-bouncer/main/install.sh)` 실행
  - 설치 옵션: commit_strategy=per-step, docs_git_track=true
- **without-dev-bounce 설정**: 빈 레포 + 프롬프트에 "팀에이전트 구성" 추가
- **디자인 전달**: 원본 경로 직접 참조 (`/Users/ram/Downloads/stitch 2/`)
- **프롬프트 요구사항**: (1) YouTube 자막→AI 요약 앱 (2) 디자인 파일 3장 참조 (3) 캐싱 데이터에 썸네일/타이틀 필수
- **브랜치**: 실행마다 독립 브랜치 (with-dev-bounce-no1, without-dev-bounce-no1 등)
- **초기 커밋**: f8e094a (빈 레포 — .gitignore + README.md만)

## 파일 구조

```
experiment/
├── prompt-with.txt             # with-dev-bounce 프롬프트 (/dev-bounce 포함)
├── prompt-without.txt          # without-dev-bounce 프롬프트 (팀에이전트 구성 포함)
├── config.env                  # 실험 파라미터
├── verify-api-contract.py      # API 계약 검증기 (핵심)
├── evaluate-run.py             # 단일 실행 메트릭 수집
├── run-claude.py               # pexpect 기반 claude 자동 실행기
├── experiment-runner.sh        # 오케스트레이터
├── aggregate-results.py        # 통계 집계 + 리포트
└── results/                    # 결과 저장 (gitignore)
```

## 프롬프트

### prompt-with.txt (with-dev-bounce)
```
/dev-bounce 유튜브 링크를 넣으면, 그 스크립트를 가져와서 AI가 요약, 정리해주는 앱이야.

기술 스택: Flutter 앱 + FastAPI 서버 + Gemini AI

기능:
1. YouTube URL 입력 → 자막 추출 (youtube-transcript-api)
2. AI 요약 (Gemini)
3. AI 채팅 (자막 기반 Q&A)

디자인 참고:
- /Users/ram/Downloads/stitch 2/_2/screen.png (홈 화면)
- /Users/ram/Downloads/stitch 2/_1/screen.png (상세 화면)
- /Users/ram/Downloads/stitch 2/_3/screen.png (히스토리 화면)

중요: 캐싱된 데이터를 볼 때 유튜브 썸네일과 타이틀이 반드시 있어야 해.

API 엔드포인트:
- POST /api/v1/transcript
- POST /api/v1/summarize
- POST /api/v1/chat

서버는 server/, 앱은 app/ 디렉토리에 만들어줘.
```

### prompt-without.txt (without-dev-bounce)
```
유튜브 링크를 넣으면, 그 스크립트를 가져와서 AI가 요약, 정리해주는 앱이야.

기술 스택: Flutter 앱 + FastAPI 서버 + Gemini AI

기능:
1. YouTube URL 입력 → 자막 추출 (youtube-transcript-api)
2. AI 요약 (Gemini)
3. AI 채팅 (자막 기반 Q&A)

디자인 참고:
- /Users/ram/Downloads/stitch 2/_2/screen.png (홈 화면)
- /Users/ram/Downloads/stitch 2/_1/screen.png (상세 화면)
- /Users/ram/Downloads/stitch 2/_3/screen.png (히스토리 화면)

중요: 캐싱된 데이터를 볼 때 유튜브 썸네일과 타이틀이 반드시 있어야 해.

API 엔드포인트:
- POST /api/v1/transcript
- POST /api/v1/summarize
- POST /api/v1/chat

서버는 server/, 앱은 app/ 디렉토리에 만들어줘.

개발 시 팀에이전트를 구성해서 진행해줘.
Planning 팀(리드, 개발관점, QA관점)으로 계획을 세우고,
Dev 팀(리드, 개발자, QA)으로 TDD 기반 개발을 진행해.
```

## 개발 Phase

1. 프롬프트 + config.env
2. verify-api-contract.py (골든 테스트: with=0건, without=6건)
3. run-claude.py (pexpect 자동 실행기) — PoC 먼저
4. evaluate-run.py (메트릭 수집)
5. experiment-runner.sh (오케스트레이터)
6. aggregate-results.py (통계 + 리포트)

## PoC 결과 (2026-03-08 확인 완료)

- ✅ pexpect로 claude interactive 자동화 가능
- ✅ `CLAUDECODE` 환경변수 unset으로 중첩 세션 차단 우회
- ✅ `send(text)` + `send('\r')`로 프롬프트 제출 성공
- ✅ 응답 수신 + 비용 추적 ($0.09) 가능
- ⚠️ ANSI 코드 많음 (90+개) — strip_ansi() 필수
- ✅ 병렬 실행 성공 (2세션 동시, 48.5초 / 순차 대비 ~50% 단축)
- ⏳ AskUserQuestion / plan approval 자동 응답은 추가 테스트 필요

## 비용 예상

~$3-5/run × 20 = $60-100
