#!/bin/bash
set -euo pipefail

SERVER="ubuntu@158.179.166.232"
REMOTE_DIR="~/youtube-helper"

echo "=== 1. 로컬 테스트 ==="
cd server
./venv/bin/python -m pytest tests/ -v
cd ..

echo "=== 2. 서버 서비스 중단 ==="
ssh "$SERVER" "sudo systemctl stop youtube-helper 2>/dev/null || true"

echo "=== 3. rsync 배포 ==="
rsync -avz --progress \
  --exclude='.env' \
  --exclude='venv/' \
  --exclude='__pycache__/' \
  --exclude='*.pyc' \
  --exclude='.git/' \
  --exclude='.worklogs/' \
  --exclude='.claude/' \
  --exclude='docs/' \
  --exclude='app/' \
  --exclude='.pytest_cache/' \
  ./server/ "$SERVER:$REMOTE_DIR/"

echo "=== 4. 서버 의존성 설치 ==="
ssh "$SERVER" "cd $REMOTE_DIR && venv/bin/pip install -r requirements.txt -q"

echo "=== 5. 서버 테스트 ==="
ssh "$SERVER" "cd $REMOTE_DIR && venv/bin/python -m pytest tests/ -v"

echo "=== 6. 서비스 재시작 ==="
ssh "$SERVER" "sudo systemctl start youtube-helper && sleep 3 && sudo journalctl -u youtube-helper -n 10 --no-pager"

echo "=== 배포 완료 ==="
