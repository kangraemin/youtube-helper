#!/usr/bin/env python3
"""PoC v4: 프롬프트 제출 방법 테스트
claude의 입력 UI는 커스텀 에디터 — Enter는 줄바꿈, 실제 제출은 다른 키일 수 있음
"""

import pexpect
import os
import time
import re

ANSI_RE = re.compile(r'\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07|\x1b[()][AB012]|\x1b\[[?]?[0-9;]*[hl]|\x1b\[[\d;]*m')

def strip_ansi(text):
    return ANSI_RE.sub('', text)

def main():
    env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}

    print("PoC v4: 프롬프트 제출 키 테스트\n")

    child = pexpect.spawn(
        'claude',
        args=['--dangerously-skip-permissions'],
        encoding='utf-8',
        timeout=60,
        dimensions=(50, 200),
        env=env,
    )

    log = open('poc-v4.log', 'w')
    child.logfile_read = log

    # 초기화 대기
    print("초기화 대기 (10초)...")
    time.sleep(10)

    # 프롬프트 입력
    prompt = '1+1은?'
    print(f"프롬프트 입력: '{prompt}'")

    # 방법 1: 텍스트 입력 후 Enter
    child.send(prompt)
    time.sleep(1)

    # Enter 키 전송 (claude에서 Enter = 제출)
    print("Enter 키 전송...")
    child.send('\r')
    time.sleep(1)

    # 혹시 Enter가 줄바꿈이면, Ctrl+Enter 또는 다른 키 시도
    # claude 기본: Enter = 제출
    # 그런데 pexpect에서 \r이 제대로 전달되는지 확인

    print("응답 대기 (30초)...")
    time.sleep(30)

    # 전체 버퍼 읽기
    try:
        child.expect([pexpect.TIMEOUT], timeout=3)
    except:
        pass

    raw = child.before or ''
    clean = strip_ansi(raw)

    # 의미있는 텍스트만 추출
    lines = [l.strip() for l in clean.split('\n') if l.strip()]
    print(f"\n출력 (비어있지 않은 줄 {len(lines)}개):")
    for line in lines[-30:]:  # 마지막 30줄
        print(f"  {line}")

    # '2' 가 응답에 있는지 확인 (1+1=2)
    if '2' in clean:
        print("\n✅ '2' 발견 — 프롬프트 제출 + 응답 수신 성공!")
    else:
        print("\n⚠️ '2' 미발견 — 제출이 안 됐거나 응답 대기 중")

    # 종료
    child.sendcontrol('c')
    time.sleep(2)
    child.send('/exit\r')
    time.sleep(3)
    try:
        child.expect(pexpect.EOF, timeout=5)
    except:
        child.terminate(force=True)

    log.close()
    print(f"\n로그: poc-v4.log")

if __name__ == '__main__':
    main()
