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
| TC-1 | build_runner build | Freezed 코드 생성 성공 |  |
| TC-2 | flutter analyze | 에러 없음 |  |

## 구현 내용
(Dev가 작성)
