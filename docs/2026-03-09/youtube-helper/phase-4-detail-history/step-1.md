# Step 1: 상세 화면 UI

## 목표
- 요약 상세 + 채팅 화면

## 구현 항목
- 탭: 스크립트 전문 / 동영상 요약 / 핵심 요점 / 챗봇
- 채팅 FAB 버튼
- 채팅 인터페이스 (메시지 입력 + 응답 표시)

## 테스트 기준 (QA 작성)
| TC | 설명 | 상태 |
|----|------|------|
| TC-1 | detail_screen.dart에 TabController length=4 존재 | ✅ PASS |
| TC-2 | 4개 탭 (스크립트 전문/동영상 요약/핵심 요점/챗봇) 존재 | ✅ PASS |
| TC-3 | 채팅 입력 TextField + send 버튼 존재 | ✅ PASS |
| TC-4 | FloatingActionButton으로 챗봇 탭 이동 | ✅ PASS |

## 완료 기준
- 탭 전환 동작
- 채팅 메시지 송수신 (API 모킹)
