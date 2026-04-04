## 목표
Provider + UI에서 서버 의존성 제거, 자막만 가져오는 흐름으로 단순화

## 범위
- summary_provider.dart: ApiService → TranscriptService, chat 제거
- home_screen.dart: 버튼 텍스트/아이콘 변경
- video_result_card.dart: summary 미리보기 제거
- summary_detail_screen.dart: 요약 탭 + 채팅 섹션 제거
- api_service.dart, api_constants.dart 삭제
- chat_message.dart + 생성파일 삭제
- settings_provider.dart: serverUrlProvider 제거
- settings_screen.dart: 서버 URL 설정 제거

## Steps
1. summary_provider.dart + 삭제 파일 처리
2. home_screen.dart + video_result_card.dart
3. summary_detail_screen.dart + settings
