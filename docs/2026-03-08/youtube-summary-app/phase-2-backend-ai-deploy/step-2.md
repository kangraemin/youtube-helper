# Step 2: Deploy Script + Systemd Service

## 완료 기준
- deploy.sh: rsync 배포 스크립트 (coinbot 패턴)
- youtube-helper.service: systemd 서비스 파일

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | deploy.sh 문법 검증 (bash -n) | 정상 | ✅ Syntax OK |
| TC-2 | youtube-helper.service 파일 존재 + 필수 필드 | ExecStart, WorkingDirectory 포함 | ✅ Service file OK |

## 구현 내용
- `deploy.sh`: 로컬 테스트 → 서비스 중단 → rsync → pip install → 서버 테스트 → 서비스 재시작
- `youtube-helper.service`: uvicorn 기반 systemd 서비스 (auto-restart, RestartSec=10)
