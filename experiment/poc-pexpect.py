#!/usr/bin/env python3
"""
PoC: pexpect로 claude interactive 세션 자동화 테스트

목적:
1. pexpect가 claude를 스폰할 수 있는지
2. 프롬프트를 전송하고 출력을 캡처할 수 있는지
3. 특정 패턴 감지 + 자동 응답이 가능한지
4. ANSI 코드 스트리핑이 필요한지 확인
"""

import pexpect
import sys
import time
import re
import os

# ANSI escape code 제거용
ANSI_RE = re.compile(r'\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07|\x1b[()][AB012]|\x1b\[[?]?[0-9;]*[hl]')

def strip_ansi(text):
    return ANSI_RE.sub('', text)

def main():
    log_file = open('poc-pexpect.log', 'w')

    print("=" * 60)
    print("PoC: pexpect + claude interactive 자동화 테스트")
    print("=" * 60)

    # 1. claude 스폰
    print("\n[1] claude 스폰 시도...")
    try:
        child = pexpect.spawn(
            'claude',
            args=['--dangerously-skip-permissions'],
            encoding='utf-8',
            timeout=60,
            dimensions=(50, 200),  # rows, cols
            env={**os.environ, 'TERM': 'dumb'},  # ANSI 최소화
        )
        child.logfile_read = log_file
        print("    ✅ claude 프로세스 스폰 성공")
    except Exception as e:
        print(f"    ❌ 스폰 실패: {e}")
        return

    # 2. 초기 출력 대기 (claude 로딩)
    print("\n[2] claude 초기화 대기 (최대 30초)...")
    time.sleep(5)  # claude 로딩 대기

    try:
        # claude가 준비되면 프롬프트가 나타남
        # 패턴: '>' 또는 입력 대기 상태
        child.expect([r'>', r'\$', pexpect.TIMEOUT], timeout=30)
        raw_output = child.before or ''
        clean_output = strip_ansi(raw_output)
        print(f"    초기 출력 (첫 500자):\n    {clean_output[:500]}")
        print("    ✅ claude 준비 완료")
    except pexpect.TIMEOUT:
        print("    ⚠️ 타임아웃 - 강제 진행")
    except pexpect.EOF:
        print("    ❌ claude가 즉시 종료됨")
        return

    # 3. 간단한 프롬프트 전송
    print("\n[3] 테스트 프롬프트 전송: '안녕, 1+1은?'")
    child.sendline('안녕, 1+1은?')

    print("    응답 대기 (최대 30초)...")
    try:
        # 응답 완료 후 다시 입력 대기 상태가 됨
        time.sleep(10)  # 응답 생성 대기
        child.expect([r'>', pexpect.TIMEOUT], timeout=30)
        raw_response = child.before or ''
        clean_response = strip_ansi(raw_response)
        print(f"    응답:\n    {clean_response[:1000]}")
        print("    ✅ 프롬프트 전송 + 응답 수신 성공")
    except pexpect.TIMEOUT:
        # 타임아웃이어도 현재까지의 출력 확인
        raw_response = child.before or ''
        clean_response = strip_ansi(raw_response)
        print(f"    ⚠️ 타임아웃, 현재까지 출력:\n    {clean_response[:1000]}")
    except pexpect.EOF:
        print("    ❌ claude 종료됨")
        return

    # 4. ANSI 코드 분석
    print("\n[4] ANSI 코드 분석...")
    raw_all = child.before or ''
    ansi_codes = re.findall(r'\x1b\[[0-9;]*[a-zA-Z]', raw_all)
    print(f"    ANSI 코드 발견: {len(ansi_codes)}개")
    if ansi_codes:
        unique_codes = set(ansi_codes[:20])
        print(f"    고유 코드 (최대 20개): {unique_codes}")

    # 5. 종료
    print("\n[5] claude 종료...")
    try:
        child.sendline('/exit')
        child.expect(pexpect.EOF, timeout=10)
        print("    ✅ 정상 종료")
    except:
        child.terminate(force=True)
        print("    ⚠️ 강제 종료")

    log_file.close()

    print("\n" + "=" * 60)
    print("PoC 결과 요약:")
    print("  1. 스폰: ✅")
    print("  2. 초기화: 위 결과 참조")
    print("  3. 프롬프트/응답: 위 결과 참조")
    print("  4. ANSI 코드: 위 결과 참조")
    print(f"\n전체 로그: poc-pexpect.log")
    print("=" * 60)

if __name__ == '__main__':
    main()
