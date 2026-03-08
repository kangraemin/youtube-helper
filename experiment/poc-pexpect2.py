#!/usr/bin/env python3
"""PoC v2: claude 스폰 실패 원인 분석"""

import pexpect
import os
import sys
import time

def test_spawn(label, cmd, args=None, env_extra=None):
    print(f"\n--- {label} ---")
    env = {**os.environ}
    if env_extra:
        env.update(env_extra)

    try:
        child = pexpect.spawn(
            cmd,
            args=args or [],
            encoding='utf-8',
            timeout=30,
            dimensions=(50, 200),
            env=env,
        )
        # 출력을 실시간으로 캡처
        child.logfile_read = sys.stdout

        # EOF 또는 타임아웃까지 대기
        try:
            child.expect(pexpect.EOF, timeout=20)
            print(f"\n[EOF] 종료코드: {child.exitstatus}, 시그널: {child.signalstatus}")
            if child.before:
                print(f"[출력]: {child.before[:2000]}")
        except pexpect.TIMEOUT:
            print(f"\n[TIMEOUT] 20초 후에도 실행 중 (좋은 신호)")
            if child.before:
                print(f"[현재 출력]: {child.before[:2000]}")
            child.terminate()

    except Exception as e:
        print(f"[ERROR] {e}")

# 테스트 1: 기본 claude
test_spawn("claude 기본", "claude")

# 테스트 2: --dangerously-skip-permissions
test_spawn("claude --dangerously-skip-permissions",
           "claude", ["--dangerously-skip-permissions"])

# 테스트 3: TERM=xterm
test_spawn("claude (TERM=xterm)",
           "claude", ["--dangerously-skip-permissions"],
           {"TERM": "xterm-256color"})
