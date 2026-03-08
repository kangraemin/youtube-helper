# YouTube Helper

YouTube 동영상 자막을 AI로 요약해주는 Flutter + FastAPI 앱.

> **이 레포는 [dev-bounce](https://github.com/anthropics/claude-code) 워크플로우 테스트용 레포입니다.**
> 동일한 요구사항을 `with-dev-bounce` / `without-dev-bounce` 두 가지 방식으로 구현하여 코드 품질을 비교합니다.

---

## 브랜치 구조

| 브랜치 | 설명 |
|--------|------|
| `main` | 비교 문서 및 공통 설정 |
| `with-dev-bounce` | dev-bounce 워크플로우로 단계별 개발 (12커밋) |
| `without-dev-bounce` | dev-bounce 없이 단일 커밋으로 개발 |

## 비교 결과 요약

자세한 분석은 [`docs/branch-comparison.md`](docs/branch-comparison.md) 참조.

| 항목 | with-dev-bounce | without-dev-bounce |
|------|:-:|:-:|
| 종합 점수 | **6.2/10** | 4.2/10 |
| Critical 버그 | 4개 | 7개 |
| 총 버그 | 9개 | 13개 |
| 커밋 수 | 12 | 1 |
| 테스트 수 (Python) | 14개 | 8개 |

### 핵심 교훈

dev-bounce 워크플로우(계획 → 구현 → 검증)가 **코드 품질 자체**보다 **개발 프로세스 품질**에서 큰 차이를 만들었다. 점진적 개발과 품질 게이트가 추가적인 서버 로직 버그 3건을 예방했고, 더 많은 테스트 작성을 유도했다.

## 기술 스택

- **Frontend**: Flutter (Dart) — Riverpod, GoRouter, Hive, Freezed
- **Backend**: FastAPI (Python) — Pydantic, Google Gemini API
- **AI**: Gemini 2.0 Flash (요약/채팅)

## 프로젝트 구조

```
youtube_helper/
├── app/                # Flutter 모바일 앱
│   └── lib/
│       ├── core/       # 상수, 테마, 유틸리티
│       ├── features/   # 요약, 히스토리, 설정
│       └── routing/    # GoRouter 설정
├── server/             # FastAPI 백엔드
│   ├── models/         # Pydantic 스키마
│   ├── routers/        # API 엔드포인트 (v1)
│   ├── services/       # 비즈니스 로직 (Gemini, YouTube)
│   └── tests/          # pytest 단위 테스트
└── docs/               # 비교 분석 문서
```

## 실행 방법

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

## 라이선스

Private — 테스트 목적 레포
