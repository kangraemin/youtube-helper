# 계획: YouTube 자막 직접 추출 (서버 없이)

## Context
기존 Flutter 앱은 FastAPI 서버 → `youtube_transcript_api` → Gemini 요약 흐름이었음.
사용자 요구: 서버 없이 YouTube URL을 주면 자막(스크립트)만 가져와서 복사할 수 있게.

작업 대상 브랜치: `feature/transcript-only` (신규, `feature/vercel-transcript-api`에서 분기)
```bash
git checkout feature/vercel-transcript-api
git checkout -b feature/transcript-only
```

---

## 모드: NORMAL (신규 클래스 + 변경 파일 5개)

---

## Phase 1: TranscriptService (서비스 레이어)

### Step 1: `transcript_service.dart` 신규 생성

**파일**: `app/lib/features/summarize/infrastructure/transcript_service.dart`

YouTube 자막을 직접(서버 없이) 가져오는 Dart 서비스.

```dart
// 핵심 로직 (Stash Android 설계서 참조)
class TranscriptService {
  static const _headers = {
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
  };

  // 1. extractVideoId: URL → video_id
  //    - youtube.com/watch?v=XXX
  //    - youtu.be/XXX
  //    - youtube.com/shorts/XXX

  // 2. fetchVideoTitle: oembed API
  //    GET https://www.youtube.com/oembed?url=...&format=json

  // 3. fetchTranscript(videoId) → List<TranscriptSegment>
  //    a. GET https://www.youtube.com/watch?v={videoId}
  //    b. HTML에서 "captionTracks":[...] 추출 (regex + dotAll)
  //    c. 언어 우선순위: ko → ko-auto → en → en-auto → 첫번째
  //    d. GET captionTrack.baseUrl → XML
  //    e. XML <text start dur>...파싱 → TranscriptSegment 리스트
  //    f. HTML 엔티티 디코딩 (&amp; &lt; &#39; 등)
}
```

**TC-01**: 실제 YouTube URL로 자막 추출 확인 (dart run 스크립트 or flutter test)

---

## Phase 2: Provider + UI 정리

### Step 1: `summary_provider.dart` 수정

**Before**: ApiService(서버) 호출 → transcript + summary + chat
**After**: TranscriptService(직접) 호출 → transcript만

- `sendChat` 메서드 삭제
- `chatMessages` 상태 삭제
- `summarize()` → `fetchTranscript()` 로 rename
- `ApiService` / `apiServiceProvider` / `serverUrlProvider` 의존성 제거
- `storageService`는 유지 (history 저장)
- `VideoSummary.summary` 필드는 빈 문자열로 유지 (freezed 재생성 불필요)

### Step 2: UI 간소화 — home + result_card

**`home_screen.dart`**
- `_summarize()` → `_fetchTranscript()`
- 버튼: "요약하기" → "스크립트 가져오기"
- 아이콘: `Icons.auto_awesome` → `Icons.subtitles`

**`video_result_card.dart`**
- summary preview 텍스트 박스 제거
- 카드: 썸네일 + 제목 + [전문 보기] + [스크립트 복사 아이콘] 만 남김

### Step 3: `summary_detail_screen.dart` 수정

- TabBar 제거 (요약 탭 없애고 스크립트 전문만)
- `_buildChatSection` 제거
- `_buildSummaryTab` 제거
- FAB: 항상 스크립트 복사 (탭 분기 제거)
- 화면: 썸네일 → 제목 → 스크립트 세그먼트 리스트 + 복사 FAB

---

## 삭제/정리

- `api_service.dart` 삭제
- `api_constants.dart` 삭제
- `chat_message.dart` + 생성 파일들 삭제
- `settings_provider.dart`: `serverUrlProvider` 제거, `isDarkModeProvider`만 유지
- `settings_screen.dart`: 서버 URL 설정 부분 제거

---

## 검증

```bash
cd app
flutter analyze  # 컴파일 에러 없음 확인
flutter build apk --debug  # 빌드 성공
```

수동 테스트:
1. YouTube URL 입력 → "스크립트 가져오기" 탭
2. 자막 있는 영상: 세그먼트 목록 표시 + 복사 동작
3. 자막 없는 영상: 에러 메시지 표시
