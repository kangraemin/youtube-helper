# Step 2: Deploy Script + Systemd Service

## 완료 기준
- deploy.sh: rsync 배포 스크립트 (coinbot 패턴)
- youtube-helper.service: systemd 서비스 파일

## 테스트 케이스
| TC | 시나리오 | 기대 결과 | 실제 결과 |
|---|---|---|---|
| TC-1 | deploy.sh 문법 검증 (bash -n) | 정상 | |
| TC-2 | youtube-helper.service 파일 존재 + 필수 필드 | ExecStart, WorkingDirectory 포함 | |

## 구현 내용
(Dev가 작성)
