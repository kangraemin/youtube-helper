#!/usr/bin/env python3
"""subprocess 기반 claude -p 자동 실행기

claude -p (print mode)를 사용하여 비대화식으로 실행.
hooks(PreToolUse, PostToolUse)는 -p 모드에서도 정상 동작.

Usage:
    python3 run-claude.py --mode with --run-number 1 --work-dir /path/to/repo
"""

import argparse
import json
import os
import re
import subprocess
import sys
import threading
import time
from pathlib import Path


def create_log_path(results_dir: str, mode: str, run_number: int) -> Path:
    log_dir = Path(results_dir)
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / f"{mode}-no{run_number}.log"


def run_claude(mode: str, run_number: int, work_dir: str, results_dir: str,
               prompt_file: str, timeout: int = 1800) -> dict:
    """단일 claude -p 세션 실행"""
    result = {
        'mode': mode,
        'run_number': run_number,
        'work_dir': work_dir,
        'success': False,
        'elapsed_seconds': 0,
        'timed_out': False,
        'error': None,
    }

    # 프롬프트 읽기
    with open(prompt_file) as f:
        prompt = f.read().strip()

    log_path = create_log_path(results_dir, f"{mode}-dev-bounce", run_number)
    branch_name = f"{mode}-dev-bounce-no{run_number}"

    # CLAUDECODE 제거 (중첩 세션 차단 우회)
    env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}

    print(f"\n{'='*60}")
    print(f"[{branch_name}] claude -p 세션 시작")
    print(f"  작업 디렉토리: {work_dir}")
    print(f"  로그: {log_path}")
    print(f"  타임아웃: {timeout}초")
    print(f"{'='*60}")

    start = time.time()

    try:
        # claude -p 실행
        cmd = [
            'claude', '-p',
            '--dangerously-skip-permissions',
            '--output-format', 'text',
            '--max-budget-usd', '20',
            prompt,
        ]

        print(f"  프롬프트 ({len(prompt)}자) 전송 중...", flush=True)

        proc = subprocess.Popen(
            cmd,
            cwd=work_dir,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        # stdout을 별도 스레드에서 읽어 로그 저장
        log_file = open(log_path, 'wb')
        stdout_chunks = []
        last_report = [start]

        def read_stdout():
            while True:
                chunk = proc.stdout.read(4096)
                if not chunk:
                    break
                stdout_chunks.append(chunk)
                log_file.write(chunk)
                log_file.flush()
                now = time.time()
                if now - last_report[0] > 30:
                    total = sum(len(c) for c in stdout_chunks)
                    elapsed = now - start
                    print(f"  [{elapsed:.0f}s] 출력: {total}바이트",
                          flush=True)
                    last_report[0] = now

        reader = threading.Thread(target=read_stdout, daemon=True)
        reader.start()

        # 타임아웃 대기
        try:
            proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            print(f"\n  ⏰ 타임아웃 ({timeout}초)", flush=True)
            proc.terminate()
            time.sleep(5)
            if proc.poll() is None:
                proc.kill()
            result['timed_out'] = True

        reader.join(timeout=10)
        log_file.close()

        stderr_data = proc.stderr.read() or b''

        full_stdout = b''.join(stdout_chunks).decode('utf-8', errors='replace')
        result['elapsed_seconds'] = time.time() - start
        result['exit_code'] = proc.returncode
        result['success'] = proc.returncode == 0 and not result['timed_out']
        result['output_chars'] = len(full_stdout)

        if stderr_data:
            stderr_text = stderr_data.decode('utf-8', errors='replace')
            stderr_log = log_path.with_suffix('.stderr.log')
            with open(stderr_log, 'w') as f:
                f.write(stderr_text)
        else:
            stderr_text = ''

        # 비용 추출 시도
        for text in [full_stdout, stderr_text]:
            cost_match = re.search(r'\$(\d+\.\d+)', text)
            if cost_match:
                result['cost_usd'] = float(cost_match.group(1))
                break

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
    print(f"  출력: {result.get('output_chars', 0)}자")
    if result.get('cost_usd'):
        print(f"  비용: ${result['cost_usd']:.2f}")
    if result.get('error'):
        print(f"  오류: {result['error']}")

    return result


def main():
    parser = argparse.ArgumentParser(description='claude -p 자동 실행기')
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
