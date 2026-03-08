#!/usr/bin/env python3
"""stream-json 기반 claude 자동 실행기

claude -p + stream-json 양방향 통신으로 실행.
AskUserQuestion, 계획 승인 등에 자동 응답.

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


# 계획 승인 트리거 패턴
APPROVAL_PATTERNS = [
    r'\[PLAN:승인대기\]',
    r'승인하시면.*시작',
    r'수정.*요청.*있으면.*말씀',
    r'승인.*하시[겠면]',
    r'승인을 기다',
    r'승인.*기다리고',
    r'승인.*부탁',
]


def create_log_path(results_dir: str, mode: str, run_number: int) -> Path:
    log_dir = Path(results_dir)
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / f"{mode}-no{run_number}.log"


def send_user_message(proc, text, lock):
    """stdin으로 사용자 메시지 전송"""
    msg = {
        "type": "user",
        "message": {
            "role": "user",
            "content": [{"type": "text", "text": text}],
        },
    }
    line = json.dumps(msg, ensure_ascii=False) + "\n"
    with lock:
        try:
            proc.stdin.write(line.encode())
            proc.stdin.flush()
        except (BrokenPipeError, OSError):
            pass


def run_claude(mode: str, run_number: int, work_dir: str, results_dir: str,
               prompt_file: str, timeout: int = 1800) -> dict:
    """단일 claude stream-json 세션 실행"""
    result = {
        'mode': mode,
        'run_number': run_number,
        'work_dir': work_dir,
        'success': False,
        'elapsed_seconds': 0,
        'timed_out': False,
        'auto_respond_count': 0,
        'error': None,
    }

    with open(prompt_file) as f:
        prompt = f.read().strip()

    log_path = create_log_path(results_dir, f"{mode}-dev-bounce", run_number)
    branch_name = f"{mode}-dev-bounce-no{run_number}"

    env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}

    print(f"\n{'='*60}")
    print(f"[{branch_name}] claude stream-json 세션 시작")
    print(f"  작업 디렉토리: {work_dir}")
    print(f"  로그: {log_path}")
    print(f"  타임아웃: {timeout}초")
    print(f"{'='*60}", flush=True)

    start = time.time()
    stdin_lock = threading.Lock()
    auto_respond_count = 0
    tool_counts = {}
    responded_this_turn = False  # 현재 턴에서 자동 응답 보냈는지
    consecutive_empty_turns = 0  # 연속 빈 턴 (작업 없이 end_turn)
    task_seems_done = False  # 작업 완료 감지

    try:
        cmd = [
            'claude', '-p',
            '--input-format', 'stream-json',
            '--output-format', 'stream-json',
            '--verbose',
            '--dangerously-skip-permissions',
            '--permission-mode', 'bypassPermissions',
            '--max-budget-usd', '20',
        ]

        proc = subprocess.Popen(
            cmd,
            cwd=work_dir,
            env=env,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        # stderr 읽기
        stderr_chunks = []
        def read_stderr():
            for line in proc.stderr:
                stderr_chunks.append(line)
        t_err = threading.Thread(target=read_stderr, daemon=True)
        t_err.start()

        # 프롬프트 전송
        initial_msg = {
            "type": "user",
            "message": {
                "role": "user",
                "content": [{"type": "text", "text": prompt}],
            },
        }
        proc.stdin.write((json.dumps(initial_msg, ensure_ascii=False) + "\n").encode())
        proc.stdin.flush()
        print(f"  프롬프트 전송 ({len(prompt)}자)", flush=True)

        # 로그 파일
        log_file = open(log_path, 'w', encoding='utf-8')
        last_report = start

        # stdout 스트림 처리
        for raw_line in proc.stdout:
            elapsed = time.time() - start

            if elapsed > timeout:
                print(f"\n  ⏰ 타임아웃 ({timeout}초)", flush=True)
                result['timed_out'] = True
                break

            decoded = raw_line.decode('utf-8', errors='replace').strip()
            if not decoded:
                continue

            # 로그 저장
            log_file.write(decoded + '\n')
            log_file.flush()

            try:
                msg = json.loads(decoded)
            except json.JSONDecodeError:
                continue

            msg_type = msg.get('type', '')

            if msg_type == 'assistant':
                content = msg.get('message', {}).get('content', [])
                for block in content:
                    block_type = block.get('type', '')

                    if block_type == 'text':
                        text = block.get('text', '')

                        # 전체 작업 완료 감지 (개별 step 완료가 아닌 전체)
                        done_patterns = [
                            r'더 이상 진행할.*없',
                            r'모든.*작업.*완료',
                            r'##.*개발 완료',
                            r'새로운.*기능.*추가.*필요하시면',
                            r'\[DONE\]',
                        ]
                        for dp in done_patterns:
                            if re.search(dp, text):
                                task_seems_done = True
                                print(f"  [{elapsed:.0f}s] [완료감지] 패턴 매치: {dp}",
                                      flush=True)
                                break

                        # 30초마다 진행 상황 표시
                        now = time.time()
                        if now - last_report > 30:
                            snippet = text[:80].replace('\n', ' ')
                            print(f"  [{elapsed:.0f}s] {snippet}", flush=True)
                            last_report = now

                        # 계획 승인 감지
                        for pat in APPROVAL_PATTERNS:
                            if re.search(pat, text):
                                time.sleep(1)
                                send_user_message(proc, "승인합니다. 진행해주세요.", stdin_lock)
                                auto_respond_count += 1
                                responded_this_turn = True
                                print(f"  [{elapsed:.0f}s] >> 자동 승인 (#{auto_respond_count})",
                                      flush=True)
                                break

                    elif block_type == 'tool_use':
                        name = block.get('name', '?')
                        inp = block.get('input', {})
                        tool_counts[name] = tool_counts.get(name, 0) + 1

                        if name == 'AskUserQuestion':
                            question = inp.get('question', '')
                            print(f"  [{elapsed:.0f}s] [질문] {question[:80]}",
                                  flush=True)
                            time.sleep(0.5)
                            send_user_message(
                                proc,
                                "네, 진행해주세요. 추가 요구사항 없습니다.",
                                stdin_lock,
                            )
                            auto_respond_count += 1
                            responded_this_turn = True
                            print(f"  [{elapsed:.0f}s] >> 자동 응답 (#{auto_respond_count})",
                                  flush=True)

                        elif name == 'TeamCreate':
                            team = inp.get('team_name', '?')
                            print(f"  [{elapsed:.0f}s] [팀생성] {team}", flush=True)

                        elif name == 'EnterPlanMode':
                            print(f"  [{elapsed:.0f}s] [PlanMode] 진입", flush=True)

                        elif name == 'ExitPlanMode':
                            print(f"  [{elapsed:.0f}s] [PlanMode] 종료", flush=True)

            elif msg_type == 'result':
                cost = msg.get('total_cost_usd') or msg.get('cost_usd')
                stop_reason = msg.get('stop_reason', '')
                if cost:
                    result['cost_usd'] = cost
                # result는 한 턴 완료 — 프로세스가 아직 살아있으면 계속 읽기
                if proc.poll() is not None:
                    print(f"  [{elapsed:.0f}s] [완료] cost=${cost}", flush=True)
                    break
                else:
                    print(f"  [{elapsed:.0f}s] [턴완료] cost=${cost}, stop={stop_reason}",
                          flush=True)
                    # end_turn 처리
                    if stop_reason == 'end_turn':
                        if responded_this_turn:
                            consecutive_empty_turns = 0
                        else:
                            consecutive_empty_turns += 1

                        # 종료 조건: 완료 감지 + 3턴 빈 응답
                        if task_seems_done and consecutive_empty_turns >= 3:
                            print(f"  [{elapsed:.0f}s] 작업 완료 + 연속 {consecutive_empty_turns}턴 — 종료",
                                  flush=True)
                            break

                        # 안전밸브: auto-continuation 40회 초과
                        if auto_respond_count >= 40:
                            print(f"  [{elapsed:.0f}s] auto-respond 40회 초과 — 종료",
                                  flush=True)
                            break

                        # continuation 전송
                        if not responded_this_turn:
                            time.sleep(1)
                            send_user_message(
                                proc,
                                "계속 진행해주세요. 승인합니다.",
                                stdin_lock,
                            )
                            auto_respond_count += 1
                            print(f"  [{elapsed:.0f}s] >> 자동 continuation (#{auto_respond_count})",
                                  flush=True)
                    responded_this_turn = False  # 다음 턴 초기화

        # 정리
        log_file.close()

        # 프로세스 종료 대기
        if proc.poll() is None:
            proc.terminate()
            time.sleep(5)
            if proc.poll() is None:
                proc.kill()

        try:
            proc.wait(timeout=30)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)

        # stderr 저장
        t_err.join(timeout=5)
        if stderr_chunks:
            stderr_text = b''.join(stderr_chunks).decode('utf-8', errors='replace')
            stderr_log = log_path.with_suffix('.stderr.log')
            with open(stderr_log, 'w') as f:
                f.write(stderr_text)

        result['elapsed_seconds'] = time.time() - start
        result['exit_code'] = proc.returncode
        result['success'] = (proc.returncode == 0 or proc.returncode is None) and not result['timed_out']
        result['auto_respond_count'] = auto_respond_count
        result['tool_counts'] = tool_counts

        # 로그 파일 크기
        result['output_chars'] = log_path.stat().st_size if log_path.exists() else 0

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
    print(f"  자동 응답: {auto_respond_count}회")
    print(f"  도구 사용: {json.dumps(tool_counts, ensure_ascii=False)}")
    if result.get('cost_usd'):
        print(f"  비용: ${result['cost_usd']:.2f}")
    if result.get('error'):
        print(f"  오류: {result['error']}")

    return result


def main():
    parser = argparse.ArgumentParser(description='claude stream-json 자동 실행기')
    parser.add_argument('--mode', choices=['with', 'without'], required=True)
    parser.add_argument('--run-number', type=int, required=True)
    parser.add_argument('--work-dir', required=True)
    parser.add_argument('--results-dir', default='experiment/results')
    parser.add_argument('--timeout', type=int, default=1800)

    args = parser.parse_args()

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
