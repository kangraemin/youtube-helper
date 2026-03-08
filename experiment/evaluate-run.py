#!/usr/bin/env python3
"""단일 실행 메트릭 수집기

Usage:
    python3 evaluate-run.py --work-dir /path/to/repo --mode with --run-number 1 --results-dir experiment/results
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path


def run_cmd(cmd, cwd=None):
    """명령 실행 후 stdout 반환"""
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd, timeout=60)
        return r.stdout.strip(), r.returncode
    except subprocess.TimeoutExpired:
        return "", -1


def count_loc(work_dir):
    """Lines of Code 계산 (server/ + app/)"""
    metrics = {'server_loc': 0, 'app_loc': 0, 'total_loc': 0}

    for subdir, key in [('server', 'server_loc'), ('app', 'app_loc')]:
        path = Path(work_dir) / subdir
        if not path.exists():
            continue
        out, _ = run_cmd(
            f"find {path} -name '*.py' -o -name '*.dart' | xargs wc -l 2>/dev/null | tail -1"
        )
        if out:
            try:
                metrics[key] = int(out.strip().split()[0])
            except (ValueError, IndexError):
                pass

    metrics['total_loc'] = metrics['server_loc'] + metrics['app_loc']
    return metrics


def count_commits(work_dir):
    """커밋 수 (initial commit 이후)"""
    out, _ = run_cmd("git rev-list --count HEAD", cwd=work_dir)
    try:
        return int(out) - 1  # initial commit 제외
    except ValueError:
        return 0


def count_files(work_dir):
    """생성된 파일 수"""
    out, _ = run_cmd("git diff --name-only f8e094a..HEAD", cwd=work_dir)
    if out:
        return len([f for f in out.split('\n') if f.strip()])
    return 0


def check_server_runnable(work_dir):
    """서버 실행 가능 여부 (import 체크)"""
    server_dir = Path(work_dir) / 'server'
    if not server_dir.exists():
        return False, "server/ 디렉토리 없음"

    main_candidates = ['main.py', 'app.py', 'server.py', 'run.py']
    main_file = None
    for f in main_candidates:
        if (server_dir / f).exists():
            main_file = f
            break

    if not main_file:
        # __init__.py 또는 다른 진입점 탐색
        out, _ = run_cmd(f"find {server_dir} -name '*.py' -path '*/main.py'")
        if out:
            main_file = out.split('\n')[0]
        else:
            return False, "진입점 파일 없음"

    # Python syntax check
    _, rc = run_cmd(f"python3 -m py_compile {server_dir / main_file}" if '/' not in main_file
                    else f"python3 -m py_compile {main_file}", cwd=work_dir)
    return rc == 0, main_file


def check_dart_analysis(work_dir):
    """Flutter 앱 분석 (dart analyze)"""
    app_dir = Path(work_dir) / 'app'
    if not app_dir.exists():
        return {'exists': False, 'errors': -1, 'warnings': -1}

    out, rc = run_cmd("dart analyze --no-fatal-infos --no-fatal-warnings 2>&1", cwd=str(app_dir))
    errors = len([l for l in out.split('\n') if 'error' in l.lower()]) if out else -1
    warnings = len([l for l in out.split('\n') if 'warning' in l.lower()]) if out else -1

    return {'exists': True, 'errors': errors, 'warnings': warnings, 'exit_code': rc}


def run_api_contract_check(work_dir):
    """API 계약 검증"""
    script = Path(__file__).parent / 'verify-api-contract.py'
    out, rc = run_cmd(f"python3 {script} {work_dir}")
    # 결과 파싱
    critical = 0
    warning = 0
    for line in out.split('\n'):
        if 'critical' in line.lower():
            m = __import__('re').search(r'(\d+)\s*critical', line, __import__('re').IGNORECASE)
            if m:
                critical = int(m.group(1))
        if 'warning' in line.lower():
            m = __import__('re').search(r'(\d+)\s*warning', line, __import__('re').IGNORECASE)
            if m:
                warning = int(m.group(1))

    return {
        'pass': rc == 0,
        'critical': critical,
        'warning': warning,
        'exit_code': rc,
    }


def check_tests(work_dir):
    """테스트 실행 결과"""
    results = {'server_tests': None, 'app_tests': None}

    # Python tests
    server_dir = Path(work_dir) / 'server'
    if server_dir.exists():
        out, rc = run_cmd("python3 -m pytest --tb=no -q 2>&1 || true", cwd=str(server_dir))
        results['server_tests'] = {
            'exit_code': rc,
            'output_summary': out[:500] if out else "",
        }

    # Flutter tests
    app_dir = Path(work_dir) / 'app'
    if app_dir.exists():
        out, rc = run_cmd("flutter test --no-pub 2>&1 || true", cwd=str(app_dir))
        results['app_tests'] = {
            'exit_code': rc,
            'output_summary': out[:500] if out else "",
        }

    return results


def check_architecture(work_dir):
    """아키텍처 구조 점검"""
    checks = {}

    # 필수 디렉토리
    for d in ['server', 'app']:
        checks[f'{d}_exists'] = (Path(work_dir) / d).exists()

    # 필수 API 엔드포인트 파일
    server_dir = Path(work_dir) / 'server'
    if server_dir.exists():
        out, _ = run_cmd(f"grep -rl 'transcript\\|summarize\\|chat' {server_dir} --include='*.py'")
        checks['api_routes_found'] = bool(out)

    # requirements.txt / pyproject.toml
    checks['has_requirements'] = (
        (Path(work_dir) / 'server' / 'requirements.txt').exists() or
        (Path(work_dir) / 'server' / 'pyproject.toml').exists()
    )

    # pubspec.yaml
    checks['has_pubspec'] = (Path(work_dir) / 'app' / 'pubspec.yaml').exists()

    return checks


def evaluate(work_dir: str, mode: str, run_number: int, results_dir: str) -> dict:
    """전체 메트릭 수집"""
    print(f"\n{'='*60}")
    print(f"메트릭 수집: {mode}-dev-bounce-no{run_number}")
    print(f"  작업 디렉토리: {work_dir}")
    print(f"{'='*60}")

    metrics = {
        'mode': mode,
        'run_number': run_number,
        'work_dir': work_dir,
    }

    # 1. LOC
    print("  [1/6] LOC 계산...")
    metrics['loc'] = count_loc(work_dir)

    # 2. 커밋 수
    print("  [2/6] 커밋 수...")
    metrics['commit_count'] = count_commits(work_dir)

    # 3. 파일 수
    print("  [3/6] 파일 수...")
    metrics['file_count'] = count_files(work_dir)

    # 4. API 계약 검증
    print("  [4/6] API 계약 검증...")
    metrics['api_contract'] = run_api_contract_check(work_dir)

    # 5. 아키텍처 점검
    print("  [5/6] 아키텍처 점검...")
    metrics['architecture'] = check_architecture(work_dir)

    # 6. 서버 구문 검사
    print("  [6/6] 서버 구문 검사...")
    runnable, detail = check_server_runnable(work_dir)
    metrics['server_runnable'] = {'pass': runnable, 'detail': detail}

    # run-claude.py 결과와 병합
    run_result_path = Path(results_dir) / f"{mode}-dev-bounce-no{run_number}.json"
    if run_result_path.exists():
        with open(run_result_path) as f:
            run_data = json.load(f)
        metrics['run'] = run_data

    # 결과 저장
    eval_path = Path(results_dir) / f"eval-{mode}-dev-bounce-no{run_number}.json"
    Path(results_dir).mkdir(parents=True, exist_ok=True)
    with open(eval_path, 'w') as f:
        json.dump(metrics, f, indent=2, ensure_ascii=False)

    print(f"\n  결과 저장: {eval_path}")

    # 요약 출력
    print(f"\n  --- 요약 ---")
    print(f"  LOC: {metrics['loc']['total_loc']} (server: {metrics['loc']['server_loc']}, app: {metrics['loc']['app_loc']})")
    print(f"  커밋: {metrics['commit_count']}, 파일: {metrics['file_count']}")
    print(f"  API 계약: {'✅ PASS' if metrics['api_contract']['pass'] else '❌ FAIL'}"
          f" ({metrics['api_contract']['critical']} critical, {metrics['api_contract']['warning']} warning)")
    print(f"  서버: {'✅' if metrics['server_runnable']['pass'] else '❌'} {metrics['server_runnable']['detail']}")

    return metrics


def main():
    parser = argparse.ArgumentParser(description='단일 실행 메트릭 수집기')
    parser.add_argument('--work-dir', required=True, help='작업 디렉토리')
    parser.add_argument('--mode', choices=['with', 'without'], required=True)
    parser.add_argument('--run-number', type=int, required=True)
    parser.add_argument('--results-dir', default='experiment/results')

    args = parser.parse_args()
    evaluate(args.work_dir, args.mode, args.run_number, args.results_dir)


if __name__ == '__main__':
    main()
