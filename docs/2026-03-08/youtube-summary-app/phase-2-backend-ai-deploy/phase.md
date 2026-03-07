# Phase 2: Backend AI + Deploy

## 개발 범위
- Gemini 서비스 (summarize_transcript, chat_about_video)
- /api/v1/summarize, /api/v1/chat 엔드포인트
- Mock 기반 테스트 (test_summarize.py)
- deploy.sh 배포 스크립트
- youtube-helper.service systemd 서비스 파일

## Step 목록
- Step 1: Gemini Service + Endpoints + Tests — gemini_service.py, api_v1.py 추가, test_summarize.py
- Step 2: Deploy Script + Systemd Service — deploy.sh, youtube-helper.service

## 이 Phase 완료 기준
- pytest tests/ -v 전체 통과
- deploy.sh, youtube-helper.service 파일 존재
