#!/usr/bin/env python3
"""PoC v3: CLAUDECODE 환경변수 제거 후 테스트"""

import pexpect
import os
import sys
import time
import re

ANSI_RE = re.compile(r'\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07|\x1b[()][AB012]|\x1b\[[?]?[0-9;]*[hl]')

def strip_ansi(text):
    return ANSI_RE.sub('', text)

def main():
    # CLAUDECODE 환경변수 제거
    env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}
    env['TERM'] = 'dumb'

    print("=" * 60)
    print("PoC v3: CLAUDECODE unset + pexpect")
    print("=" * 60)

    print("\n[1] claude 스폰 (CLAUDECODE unset)...")
    child = pexpect.spawn(
        'claude',
        args=['--dangerously-skip-permissions'],
        encoding='utf-8',
        timeout=60,
        dimensions=(50, 200),
        env=env,
    )

    log = open('poc-v3.log', 'w')
    child.logfile_read = log

    # 초기화 대기
    print("[2] 초기화 대기...")
    time.sleep(8)

    # 현재까지의 출력 확인
    try:
        child.expect([r'.+', pexpect.TIMEOUT], timeout=15)
        raw = child.before or ''
        raw += child.after if isinstance(child.after, str) else ''
        clean = strip_ansi(raw)
        print(f"    초기 출력:\n{clean[:1000]}")
    except pexpect.EOF:
        print("    ❌ EOF - claude 종료됨")
        log.close()
        return
    except pexpect.TIMEOUT:
        print("    ⚠️ 타임아웃 - 출력 없음 (UI 렌더링 중일 수 있음)")

    # 프롬프트 전송
    print("\n[3] '1+1은?' 전송...")
    child.sendline('1+1은?')

    print("    응답 대기 (최대 30초)...")
    time.sleep(15)

    # 버퍼 읽기
    try:
        child.expect([pexpect.TIMEOUT], timeout=5)
    except:
        pass

    raw_all = child.before or ''
    clean_all = strip_ansi(raw_all)
    print(f"    전체 출력:\n{clean_all[:2000]}")

    # ANSI 분석
    ansi_count = len(re.findall(r'\x1b\[', raw_all))
    print(f"\n[4] ANSI escape 시퀀스: {ansi_count}개")

    # 종료
    print("\n[5] 종료...")
    try:
        child.sendline('/exit')
        child.expect(pexpect.EOF, timeout=10)
        print("    ✅ 정상 종료")
    except:
        child.terminate(force=True)
        print("    ⚠️ 강제 종료")

    log.close()
    print(f"\n전체 로그: poc-v3.log")

if __name__ == '__main__':
    main()
