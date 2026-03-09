# 검증 2회차 — 코드 품질

## 변경 코드 리뷰

- `server/main.py`: FastAPI 앱 초기화, 라우터 등록, health 엔드포인트. 구조 깔끔. 이슈 없음.
- `server/schemas.py`: Pydantic 모델 정의. `chapters: list[dict]`는 타입이 느슨하지만 기능상 문제 없음 (Minor).
- `server/routers/transcript.py`: URL 파싱, 메타데이터, 자막 조회 각각 try-except로 분리. 적절한 HTTP 상태코드 반환. 이슈 없음.
- `server/routers/summarize.py`: `get_video_metadata` 호출에 try-except 없음 — 실패 시 500 에러가 FastAPI 기본 핸들러로 전달됨. transcript 라우터에서는 감싸고 있어 불일치 (Minor).
- `server/routers/chat.py`: 단순 구조, 예외 처리 적절. 이슈 없음.
- `server/services/youtube.py`: video_id 추출 정규식 3패턴 지원. oEmbed API 실패 시 fallback 반환 (빈 title). `get_transcript`는 예외를 호출자에게 전파 — 의도된 설계. 이슈 없음.
- `server/services/gemini.py`: lazy 클라이언트 초기화, API 키 미설정 시 명시적 에러. 프롬프트 내 `transcript[:8000]` 잘림 처리는 합리적. JSON 파싱 실패 시 fallback 처리 적절. `chat_with_transcript`의 `history` 파라미터 기본값이 mutable `None`이나 `if history:` 체크로 안전. 이슈 없음.
- `app/lib/main.dart`: StatefulWidget 기반 바텀 네비게이션. IndexedStack 사용으로 화면 상태 유지. 이슈 없음.
- `app/lib/models/video_data.dart`: JSON 직렬화/역직렬화에 null 안전 처리(`?? ''`, `?? []`). `DateTime.parse` 실패 시 예외 발생 가능하나 자체 생성 데이터이므로 실질적 위험 낮음 (Minor).
- `app/lib/services/api_service.dart`: HTTP 에러 시 Exception throw. `jsonDecode` 실패 가능성 있으나 서버가 항상 JSON 반환하므로 실질적 위험 낮음 (Minor).
- `app/lib/services/storage_service.dart`: SharedPreferences 기반 히스토리 관리. 중복 제거, 최대 50개 제한 처리 적절. 이슈 없음.
- `app/lib/screens/home_screen.dart`: URL 입력 -> 자막 조회 -> 요약 흐름. 로딩/에러 상태 관리 적절. dispose에서 컨트롤러 정리. 이슈 없음.
- `app/lib/screens/detail_screen.dart`: TabBar 4탭 구성. Image.network에 errorBuilder 적용. 이슈 없음.
- `app/lib/screens/history_screen.dart`: 리스트 빌더 + 풀 리프레시. `_getTimeAgo`에서 0분 전 표시 가능 (Minor). intl 패키지 import 있으나 DateFormat만 사용.
- `app/lib/screens/chat_screen.dart`: 메시지 송수신, 스크롤 자동 이동 처리. 에러를 assistant 메시지로 표시하여 UX 유지. 이슈 없음.

## 발견된 이슈

### Minor
1. `server/schemas.py` — `chapters: list[dict]` 타입이 느슨함. `list[ChapterSchema]` 등 구체적 타입이 더 좋으나 기능상 문제없음.
2. `server/routers/summarize.py` L16 — `get_video_metadata(video_id)` 호출이 try-except 없이 노출. transcript 라우터에서는 감싸고 있어 일관성 부재. 실패 시 FastAPI 기본 500 반환되므로 치명적이지 않음.
3. `app/lib/services/api_service.dart` — `jsonDecode` 호출에 별도 예외 처리 없음. 서버가 비정상 응답(HTML 등) 반환 시 FormatException 발생 가능. 이미 statusCode 체크로 1차 방어됨.
4. `app/lib/screens/history_screen.dart` — `_getTimeAgo`에서 `diff.inMinutes < 60` 조건에 0분일 때 "0분 전" 표시. "방금 전" 처리가 더 자연스러움.
5. `app/lib/models/video_data.dart` — `DateTime.parse(json['created_at'])` 파싱 실패 시 FormatException. 자체 직렬화 데이터이므로 실질 위험 낮음.

### Critical / Important
- 없음.

## 결론
통과 / 발견된 이슈 모두 Minor 수준. Critical/Important 이슈 없음. 에러 핸들링, null 안전 처리, 상태 관리 등 전반적으로 양호.
