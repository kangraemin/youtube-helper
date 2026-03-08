#!/usr/bin/env python3
"""PoC: claude 병렬 실행 테스트 — 2개 동시 스폰"""

import pexpect
import os
import time
import re
import threading

ANSI_RE = re.compile(r'\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07|\x1b[()][AB012]|\x1b\[[?]?[0-9;]*[hl]|\x1b\[[\d;]*m')

def strip_ansi(text):
    return ANSI_RE.sub('', text)

def run_claude(session_id, prompt, results):
    """단일 claude 세션 실행"""
    env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}
    start = time.time()

    try:
        child = pexpect.spawn(
            'claude',
            args=['--dangerously-skip-permissions'],
            encoding='utf-8',
            timeout=60,
            dimensions=(50, 200),
            env=env,
        )

        # 초기화 대기
        time.sleep(10)

        # 프롬프트 전송
        child.send(prompt)
        time.sleep(0.5)
        child.send('\r')

        # 응답 대기
        time.sleep(30)

        # 버퍼 읽기
        try:
            child.expect([pexpect.TIMEOUT], timeout=3)
        except:
            pass

        raw = child.before or ''
        clean = strip_ansi(raw)
        elapsed = time.time() - start

        results[session_id] = {
            'success': len(clean) > 50,
            'output_len': len(clean),
            'elapsed': elapsed,
            'snippet': clean[-200:] if clean else '(empty)',
        }

        # 종료
        child.sendcontrol('c')
        time.sleep(1)
        child.send('/exit\r')
        time.sleep(2)
        try:
            child.expect(pexpect.EOF, timeout=5)
        except:
            child.terminate(force=True)

    except Exception as e:
        results[session_id] = {
            'success': False,
            'error': str(e),
            'elapsed': time.time() - start,
        }

def main():
    print("=" * 60)
    print("PoC: claude 병렬 실행 (2개 동시)")
    print("=" * 60)

    results = {}
    threads = []

    prompts = {
        'session-1': '1+1은? 숫자만 답해',
        'session-2': '2+2는? 숫자만 답해',
    }

    start = time.time()

    for sid, prompt in prompts.items():
        t = threading.Thread(target=run_claude, args=(sid, prompt, results))
        threads.append(t)
        print(f"[{sid}] 스폰: '{prompt}'")
        t.start()
        time.sleep(1)  # 약간의 딜레이

    print(f"\n모든 세션 시작됨. 응답 대기...")

    for t in threads:
        t.join(timeout=90)

    total = time.time() - start
    print(f"\n{'=' * 60}")
    print(f"결과 (총 {total:.1f}초):")
    print(f"{'=' * 60}")

    for sid, res in results.items():
        if res.get('error'):
            print(f"\n[{sid}] ❌ 실패: {res['error']}")
        else:
            status = '✅' if res['success'] else '⚠️'
            print(f"\n[{sid}] {status} 출력 {res['output_len']}자, {res['elapsed']:.1f}초")
            print(f"  마지막 200자: {res['snippet'][:200]}")

    both_ok = all(r.get('success') for r in results.values())
    print(f"\n{'=' * 60}")
    if both_ok:
        print("✅ 병렬 실행 성공! 두 세션 모두 응답 수신")
    else:
        print("⚠️ 일부 세션 실패 — 상세 결과 확인 필요")
    print(f"{'=' * 60}")

if __name__ == '__main__':
    main()
