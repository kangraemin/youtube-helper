#!/usr/bin/env python3
"""pexpect 기반 claude interactive 자동 실행기

Usage:
    python3 run-claude.py --mode with --run-number 1 --work-dir /path/to/repo
    python3 run-claude.py --mode without --run-number 1 --work-dir /path/to/repo
"""

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path

import pexpect

ANSI_RE = re.compile(
    r'\x1b\[[0-9;]*[a-zA-Z]'
    r'|\x1b\].*?\x07'
    r'|\x1b[()][AB012]'
    r'|\x1b\[\??\d+[hl]'
    r'|\x1b\[[\d;]*m'
)

# claude가 작업 완료 후 보이는 패턴
IDLE_PATTERNS = [
    r'>\s*$',           # 프롬프트 대기 상태
    r'─{20,}',         # 구분선 (작업 완료 후)
]

# 자동 응답이 필요한 패턴
AUTO_RESPOND = {
    # dev-bounce 관련
    r'승인|시작|진행': '승인',
    r'\[PLAN:승인대기\]': '승인',
    # AskUserQuestion 패턴
    r'질문|확인.*필요|선택.*해주세요': '네, 진행해주세요',
    # plan mode approval
    r'계획.*확인|plan.*review': '승인',
}


def strip_ansi(text: str) -> str:
    return ANSI_RE.sub('', text)


def create_log_path(results_dir: str, mode: str, run_number: int) -> Path:
    log_dir = Path(results_dir)
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / f"{mode}-no{run_number}.log"


def install_ai_bouncer(child, timeout=120):
    """ai-bouncer 설치 자동화 (with-dev-bounce 모드 전용)"""
    install_cmd = 'bash <(curl -sL https://raw.githubusercontent.com/kangraemin/ai-bouncer/main/install.sh)'

    child.sendline(install_cmd)
    time.sleep(5)

    # 설치 프롬프트 자동 응답
    install_responses = [
        # 설치 모드 (로컬)
        (r'local|global|설치.*모드', '1'),      # 로컬 설치
        # 커밋 전략
        (r'commit.*strategy|커밋.*전략', '2'),   # per-step
        # docs git track
        (r'docs.*git|문서.*추적', '1'),          # true (추적)
        # 기타 확인
        (r'proceed|진행|계속|확인', 'y'),
        (r'\(y/n\)', 'y'),
    ]

    start = time.time()
    while time.time() - start < timeout:
        try:
            child.expect([pexpect.TIMEOUT], timeout=3)
        except:
            pass

        output = strip_ansi(child.before or '')

        responded = False
        for pattern, response in install_responses:
            if re.search(pattern, output, re.IGNORECASE):
                child.sendline(response)
                time.sleep(2)
                responded = True
                break

        if not responded and ('설치 완료' in output or 'installed' in output.lower()
                             or 'success' in output.lower()):
            print("  ai-bouncer 설치 완료")
            return True

        if time.time() - start > timeout:
            print("  ⚠️ ai-bouncer 설치 타임아웃")
            return False

    return False


def wait_for_idle(child, timeout=1800, check_interval=30):
    """claude가 작업을 완료할 때까지 대기.

    전략: check_interval 초마다 출력 버퍼를 확인.
    연속으로 2번 새 출력이 없으면 완료로 판단.
    """
    no_output_count = 0
    last_output_len = 0
    total_output = ""
    auto_respond_count = 0
    start = time.time()

    while time.time() - start < timeout:
        try:
            child.expect([pexpect.TIMEOUT], timeout=check_interval)
        except:
            pass

        new_output = child.before or ''
        total_output += new_output
        clean = strip_ansi(new_output)

        if len(clean.strip()) == 0:
            no_output_count += 1
            elapsed = time.time() - start
            print(f"  [{elapsed:.0f}s] 새 출력 없음 (연속 {no_output_count}회)")
        else:
            no_output_count = 0
            elapsed = time.time() - start
            # 마지막 줄만 표시
            last_line = [l for l in clean.strip().split('\n') if l.strip()]
            snippet = last_line[-1][:80] if last_line else "(empty)"
            print(f"  [{elapsed:.0f}s] 출력 수신: ...{snippet}")

            # 자동 응답 체크
            for pattern, response in AUTO_RESPOND.items():
                if re.search(pattern, clean):
                    print(f"  → 자동 응답: '{response}'")
                    child.send(response)
                    time.sleep(0.5)
                    child.send('\r')
                    auto_respond_count += 1
                    no_output_count = 0
                    break

        # 연속 2회 출력 없음 → 완료 (최소 60초 경과 후)
        if no_output_count >= 2 and (time.time() - start) > 60:
            print(f"  작업 완료 감지 (연속 {no_output_count}회 무출력)")
            break

    elapsed = time.time() - start
    return {
        'total_output': total_output,
        'elapsed_seconds': elapsed,
        'auto_respond_count': auto_respond_count,
        'timed_out': (time.time() - start) >= timeout,
    }


def run_claude(mode: str, run_number: int, work_dir: str, results_dir: str,
               prompt_file: str, timeout: int = 1800) -> dict:
    """단일 claude 세션 실행"""
    result = {
        'mode': mode,
        'run_number': run_number,
        'work_dir': work_dir,
        'success': False,
        'elapsed_seconds': 0,
        'auto_respond_count': 0,
        'timed_out': False,
        'error': None,
    }

    # 프롬프트 읽기
    with open(prompt_file) as f:
        prompt = f.read().strip()

    log_path = create_log_path(results_dir, f"{mode}-dev-bounce", run_number)

    # CLAUDECODE 제거 (중첩 세션 차단 우회)
    env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}

    print(f"\n{'='*60}")
    print(f"[{mode}-no{run_number}] claude 세션 시작")
    print(f"  작업 디렉토리: {work_dir}")
    print(f"  로그: {log_path}")
    print(f"{'='*60}")

    start = time.time()

    try:
        child = pexpect.spawn(
            'claude',
            args=['--dangerously-skip-permissions'],
            encoding='utf-8',
            timeout=timeout,
            dimensions=(50, 200),
            env=env,
            cwd=work_dir,
        )

        # 로그 파일
        log_file = open(log_path, 'w')
        child.logfile_read = log_file

        # 초기화 대기
        print("  claude 초기화 대기 (15초)...")
        time.sleep(15)

        # with 모드: ai-bouncer 설치 먼저
        if mode == 'with':
            print("  ai-bouncer 설치 중...")
            # ai-bouncer는 claude 밖에서 별도로 설치해야 함
            # 여기서는 프롬프트에 /dev-bounce가 포함되어 있으므로 그냥 진행

        # 프롬프트 전송
        print(f"  프롬프트 전송 ({len(prompt)}자)...")
        child.send(prompt)
        time.sleep(1)
        child.send('\r')

        # 작업 완료 대기
        print("  작업 진행 중...")
        wait_result = wait_for_idle(child, timeout=timeout)

        result['elapsed_seconds'] = time.time() - start
        result['auto_respond_count'] = wait_result['auto_respond_count']
        result['timed_out'] = wait_result['timed_out']
        result['success'] = not wait_result['timed_out']

        # 비용 추출 시도
        clean_output = strip_ansi(wait_result['total_output'])
        cost_match = re.search(r'\$(\d+\.\d+)', clean_output)
        if cost_match:
            result['cost_usd'] = float(cost_match.group(1))

        # 종료
        print("  claude 종료 중...")
        child.sendcontrol('c')
        time.sleep(2)
        child.send('/exit\r')
        time.sleep(3)
        try:
            child.expect(pexpect.EOF, timeout=10)
        except:
            child.terminate(force=True)

        log_file.close()

        # 로그 파일에서 추가 메트릭 추출
        with open(log_path) as f:
            full_log = f.read()
        clean_log = strip_ansi(full_log)
        result['output_chars'] = len(clean_log)

    except Exception as e:
        result['error'] = str(e)
        result['elapsed_seconds'] = time.time() - start
        print(f"  ❌ 오류: {e}")

    # 결과 JSON 저장
    result_json_path = Path(results_dir) / f"{mode}-dev-bounce-no{run_number}.json"
    with open(result_json_path, 'w') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    status = '✅' if result['success'] else '❌'
    print(f"\n  {status} 완료: {result['elapsed_seconds']:.0f}초")
    if result.get('cost_usd'):
        print(f"  비용: ${result['cost_usd']:.2f}")

    return result


def main():
    parser = argparse.ArgumentParser(description='claude interactive 자동 실행기')
    parser.add_argument('--mode', choices=['with', 'without'], required=True,
                        help='실험 모드 (with/without dev-bounce)')
    parser.add_argument('--run-number', type=int, required=True,
                        help='실행 번호')
    parser.add_argument('--work-dir', required=True,
                        help='작업 디렉토리 (git repo)')
    parser.add_argument('--results-dir', default='experiment/results',
                        help='결과 저장 디렉토리')
    parser.add_argument('--timeout', type=int, default=1800,
                        help='최대 실행 시간 (초, 기본 1800)')

    args = parser.parse_args()

    # 프롬프트 파일 경로
    script_dir = Path(__file__).parent
    prompt_file = script_dir / f"prompt-{'with' if args.mode == 'with' else 'without'}.txt"

    if not prompt_file.exists():
        print(f"❌ 프롬프트 파일 없음: {prompt_file}")
        sys.exit(1)

    if not Path(args.work_dir).exists():
        print(f"❌ 작업 디렉토리 없음: {args.work_dir}")
        sys.exit(1)

    result = run_claude(
        mode=args.mode,
        run_number=args.run_number,
        work_dir=args.work_dir,
        results_dir=args.results_dir,
        prompt_file=str(prompt_file),
        timeout=args.timeout,
    )

    sys.exit(0 if result['success'] else 1)


if __name__ == '__main__':
    main()
