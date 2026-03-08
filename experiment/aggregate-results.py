#!/usr/bin/env python3
"""통계 집계 + 리포트 생성

Usage:
    python3 aggregate-results.py --results-dir experiment/results
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime

try:
    from scipy.stats import mannwhitneyu
    HAS_SCIPY = True
except ImportError:
    HAS_SCIPY = False


def load_eval_results(results_dir: str) -> dict:
    """eval-*.json 파일들 로드"""
    results = {'with': [], 'without': []}

    for f in sorted(Path(results_dir).glob('eval-*.json')):
        with open(f) as fp:
            data = json.load(fp)
        mode = data.get('mode', '')
        if mode in results:
            results[mode].append(data)

    return results


def safe_mean(values):
    return sum(values) / len(values) if values else 0


def safe_median(values):
    if not values:
        return 0
    s = sorted(values)
    n = len(s)
    if n % 2 == 0:
        return (s[n//2 - 1] + s[n//2]) / 2
    return s[n//2]


def extract_metric(results: list, path: str):
    """중첩 딕셔너리에서 값 추출 (예: 'loc.total_loc')"""
    values = []
    for r in results:
        obj = r
        for key in path.split('.'):
            if isinstance(obj, dict):
                obj = obj.get(key)
            else:
                obj = None
                break
        if obj is not None and isinstance(obj, (int, float)):
            values.append(obj)
    return values


def mann_whitney(with_vals, without_vals):
    """Mann-Whitney U 검정"""
    if not HAS_SCIPY or len(with_vals) < 2 or len(without_vals) < 2:
        return {'U': None, 'p_value': None, 'significant': None}

    try:
        u_stat, p_value = mannwhitneyu(with_vals, without_vals, alternative='two-sided')
        return {
            'U': float(u_stat),
            'p_value': float(p_value),
            'significant': p_value < 0.05,
        }
    except Exception:
        return {'U': None, 'p_value': None, 'significant': None}


def generate_report(results: dict, results_dir: str):
    """마크다운 리포트 생성"""
    with_data = results['with']
    without_data = results['without']

    metrics_config = [
        ('API Contract (critical)', 'api_contract.critical', 'lower_better'),
        ('API Contract (warning)', 'api_contract.warning', 'lower_better'),
        ('Total LOC', 'loc.total_loc', 'neutral'),
        ('Server LOC', 'loc.server_loc', 'neutral'),
        ('App LOC', 'loc.app_loc', 'neutral'),
        ('Commit Count', 'commit_count', 'neutral'),
        ('File Count', 'file_count', 'neutral'),
    ]

    # 실행 시간/비용은 run-claude.py 결과에서
    run_metrics = [
        ('Elapsed (sec)', 'run.elapsed_seconds', 'lower_better'),
        ('Cost (USD)', 'run.cost_usd', 'lower_better'),
    ]

    lines = []
    lines.append(f"# Experiment Report: dev-bounce A/B Test")
    lines.append(f"")
    lines.append(f"Generated: {datetime.now().isoformat()}")
    lines.append(f"")
    lines.append(f"## Overview")
    lines.append(f"")
    lines.append(f"| | with-dev-bounce | without-dev-bounce |")
    lines.append(f"|---|---|---|")
    lines.append(f"| Runs | {len(with_data)} | {len(without_data)} |")

    # API contract pass rate
    with_pass = sum(1 for d in with_data if d.get('api_contract', {}).get('pass', False))
    without_pass = sum(1 for d in without_data if d.get('api_contract', {}).get('pass', False))
    lines.append(f"| API Contract Pass | {with_pass}/{len(with_data)} | {without_pass}/{len(without_data)} |")

    # Server runnable rate
    with_run = sum(1 for d in with_data if d.get('server_runnable', {}).get('pass', False))
    without_run = sum(1 for d in without_data if d.get('server_runnable', {}).get('pass', False))
    lines.append(f"| Server Runnable | {with_run}/{len(with_data)} | {without_run}/{len(without_data)} |")

    lines.append(f"")
    lines.append(f"## Detailed Metrics")
    lines.append(f"")
    lines.append(f"| Metric | with (mean ± med) | without (mean ± med) | p-value | Sig? |")
    lines.append(f"|---|---|---|---|---|")

    all_metrics = metrics_config + run_metrics

    for label, path, direction in all_metrics:
        w_vals = extract_metric(with_data, path)
        wo_vals = extract_metric(without_data, path)

        w_mean = safe_mean(w_vals)
        w_med = safe_median(w_vals)
        wo_mean = safe_mean(wo_vals)
        wo_med = safe_median(wo_vals)

        mw = mann_whitney(w_vals, wo_vals)
        p_str = f"{mw['p_value']:.4f}" if mw['p_value'] is not None else "N/A"
        sig_str = "✅" if mw.get('significant') else ("❌" if mw['significant'] is not None else "N/A")

        lines.append(f"| {label} | {w_mean:.1f} ± {w_med:.1f} | {wo_mean:.1f} ± {wo_med:.1f} | {p_str} | {sig_str} |")

    lines.append(f"")
    lines.append(f"## Raw Data")
    lines.append(f"")

    for mode_label, data in [("with-dev-bounce", with_data), ("without-dev-bounce", without_data)]:
        lines.append(f"### {mode_label}")
        lines.append(f"")
        if not data:
            lines.append("(no data)")
            lines.append("")
            continue

        lines.append(f"| Run | LOC | Commits | API Critical | Server OK | Elapsed |")
        lines.append(f"|---|---|---|---|---|---|")
        for d in data:
            run_num = d.get('run_number', '?')
            loc = d.get('loc', {}).get('total_loc', 0)
            commits = d.get('commit_count', 0)
            api_crit = d.get('api_contract', {}).get('critical', '?')
            srv = '✅' if d.get('server_runnable', {}).get('pass') else '❌'
            elapsed = d.get('run', {}).get('elapsed_seconds', 0)
            lines.append(f"| {run_num} | {loc} | {commits} | {api_crit} | {srv} | {elapsed:.0f}s |")
        lines.append("")

    if not HAS_SCIPY:
        lines.append("> ⚠️ scipy 미설치 — Mann-Whitney U 검정 스킵됨. `pip install scipy`로 설치 후 재실행.")
        lines.append("")

    report = '\n'.join(lines)

    # 파일 저장
    report_path = Path(results_dir) / 'report.md'
    with open(report_path, 'w') as f:
        f.write(report)

    print(report)
    print(f"\n리포트 저장: {report_path}")

    # JSON 요약도 저장
    summary = {
        'generated': datetime.now().isoformat(),
        'with_count': len(with_data),
        'without_count': len(without_data),
        'with_api_pass_rate': with_pass / len(with_data) if with_data else 0,
        'without_api_pass_rate': without_pass / len(without_data) if without_data else 0,
    }
    summary_path = Path(results_dir) / 'summary.json'
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)


def main():
    parser = argparse.ArgumentParser(description='통계 집계 + 리포트')
    parser.add_argument('--results-dir', default='experiment/results')
    args = parser.parse_args()

    if not Path(args.results_dir).exists():
        print(f"❌ 결과 디렉토리 없음: {args.results_dir}")
        sys.exit(1)

    results = load_eval_results(args.results_dir)

    if not results['with'] and not results['without']:
        print("❌ 평가 결과 파일 없음 (eval-*.json)")
        sys.exit(1)

    generate_report(results, args.results_dir)


if __name__ == '__main__':
    main()
