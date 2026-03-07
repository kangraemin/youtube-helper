# Step 2: 도메인 엔티티 + 서비스

## 완료 기준
- VideoSummary Freezed 모델 (videoId, title, thumbnailUrl, fullText, summary, transcript segments, createdAt)
- ChatMessage Freezed 모델 (role, content)
- ApiService (fetchTranscript, fetchSummary, sendChat)
- StorageService (Hive CRUD)
- Riverpod providers
- build_runner 성공

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | build_runner build | Freezed 코드 생성 성공 | ✅ PASS (6 outputs) |
| TC-2 | flutter analyze | 에러 없음 | ✅ PASS |

## 구현 내용
- video_summary.dart: VideoSummary + TranscriptSegment (Freezed + JSON serializable)
- chat_message.dart: ChatMessage (Freezed + JSON serializable)
- api_service.dart: fetchTranscript, fetchSummary, sendChat (HTTP POST)
- storage_service.dart: Hive-based CRUD (JSON string storage)
- summary_provider.dart: SummaryNotifier (summarize flow with progress, chat)
- settings_provider.dart: DarkModeNotifier, ServerUrlNotifier (Hive persisted)
- history_provider.dart: HistoryNotifier (refresh, delete, clearAll)

## 변경 파일
- `app/lib/features/summarize/domain/entities/video_summary.dart`
- `app/lib/features/summarize/domain/entities/chat_message.dart`
- `app/lib/features/summarize/infrastructure/api_service.dart`
- `app/lib/features/summarize/infrastructure/storage_service.dart`
- `app/lib/features/summarize/application/summary_provider.dart`
- `app/lib/features/summarize/application/settings_provider.dart`
- `app/lib/features/summarize/application/history_provider.dart`

## 빌드
명령: flutter pub run build_runner build --delete-conflicting-outputs
결과: Built with build_runner in 15s; wrote 6 outputs
