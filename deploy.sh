#!/usr/bin/env bash
set -euo pipefail

SERVER="ubuntu@158.179.166.232"
REMOTE_DIR="/home/ubuntu/youtube_helper"

echo "==> Syncing files..."
rsync -avz --exclude='venv' --exclude='__pycache__' --exclude='.env' \
  server/ "$SERVER:$REMOTE_DIR/server/"

echo "==> Installing dependencies & restarting service..."
ssh "$SERVER" << 'REMOTE'
cd /home/ubuntu/youtube_helper/server
python3 -m venv venv 2>/dev/null || true
./venv/bin/pip install -q -r requirements.txt
sudo systemctl restart youtube-helper
sudo systemctl status youtube-helper --no-pager
REMOTE

echo "==> Done!"
