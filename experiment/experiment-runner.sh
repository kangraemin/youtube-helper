#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Experiment Runner: dev-bounce A/B 반복 비교 오케스트레이터
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.env"

# CLI args
DRY_RUN=false
START_RUN=1
END_RUN="$NUM_RUNS"
MODE_FILTER=""  # "with", "without", or "" (both)

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)    DRY_RUN=true; shift ;;
        --start)      START_RUN=$2; shift 2 ;;
        --end)        END_RUN=$2; shift 2 ;;
        --mode)       MODE_FILTER=$2; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--start N] [--end N] [--mode with|without]"
            exit 0
            ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

RESULTS_DIR="$REPO_ROOT/$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

echo "============================================================"
echo "Experiment: $EXPERIMENT_NAME"
echo "  Runs: $START_RUN ~ $END_RUN"
echo "  Mode: ${MODE_FILTER:-both}"
echo "  Initial commit: $INITIAL_COMMIT"
echo "  Results: $RESULTS_DIR"
echo "  Dry run: $DRY_RUN"
echo "============================================================"

# ============================================================
# 단일 실행 함수
# ============================================================
run_single() {
    local mode=$1      # "with" or "without"
    local run_num=$2
    local branch_name="${mode}-dev-bounce-no${run_num}"
    local work_dir="/tmp/experiment-${branch_name}"

    echo ""
    echo "────────────────────────────────────────"
    echo "[${branch_name}] 시작"
    echo "────────────────────────────────────────"

    if $DRY_RUN; then
        echo "  [DRY RUN] 스킵"
        return 0
    fi

    # 1. 워크트리 생성 (기존 있으면 제거)
    if [ -d "$work_dir" ]; then
        echo "  기존 워크트리 제거: $work_dir"
        git -C "$REPO_ROOT" worktree remove "$work_dir" --force 2>/dev/null || rm -rf "$work_dir"
    fi

    # 브랜치가 이미 있으면 삭제
    git -C "$REPO_ROOT" branch -D "$branch_name" 2>/dev/null || true

    echo "  워크트리 생성: $work_dir (from $INITIAL_COMMIT)"
    git -C "$REPO_ROOT" worktree add -b "$branch_name" "$work_dir" "$INITIAL_COMMIT"

    # 2. with 모드: ai-bouncer 설치 + experiment override
    if [ "$mode" = "with" ]; then
        echo "  ai-bouncer 설치 중..."
        install_ai_bouncer "$work_dir"

        # Plan mode 금지 + 커밋 전략 none (자동화 환경 대응)
        echo "  experiment override 적용 중..."
        cat >> "$work_dir/.claude/CLAUDE.md" << 'OVERRIDE'

# --- experiment override ---
## CRITICAL: Plan Mode 금지
이 세션은 자동화 실험 환경입니다. 다음 규칙을 반드시 따르세요:

1. **EnterPlanMode, ExitPlanMode 도구를 절대 사용하지 마세요.** 자동화 환경에서 작동하지 않습니다.
2. 계획 수립은 plan mode 없이 직접 수행하세요. 코드 탐색, Q&A, plan.md 작성 등 모든 과정을 plan mode 밖에서 진행합니다.
3. dev-bounce 워크플로우의 나머지 구조(Phase 0→1→2→3→4, state.json, plan-gate 등)는 그대로 따르세요.
4. AskUserQuestion 대신 자체 판단으로 진행하세요. 사용자 입력을 기다리지 마세요.
5. 계획이 완성되면 plan.md를 작성하고 바로 plan_approved = true로 설정 후 개발을 시작하세요.
6. 커밋/푸시는 하지 마세요 (원격 저장소가 없습니다).
# --- experiment override end ---
OVERRIDE

        python3 -c "
import json
f = '$work_dir/.claude/ai-bouncer/config.json'
with open(f) as fp: cfg = json.load(fp)
cfg['commit_strategy'] = 'none'
cfg['commit_skill'] = False
with open(f, 'w') as fp: json.dump(cfg, fp, indent=2)
"
    fi

    # 3. claude 실행
    echo "  claude 실행 중..."
    python3 "$SCRIPT_DIR/run-claude.py" \
        --mode "$mode" \
        --run-number "$run_num" \
        --work-dir "$work_dir" \
        --results-dir "$RESULTS_DIR" \
        --timeout "$CLAUDE_TIMEOUT" || true

    # 4. 메트릭 수집
    echo "  메트릭 수집 중..."
    python3 "$SCRIPT_DIR/evaluate-run.py" \
        --mode "$mode" \
        --run-number "$run_num" \
        --work-dir "$work_dir" \
        --results-dir "$RESULTS_DIR" || true

    # 5. 워크트리 내 변경사항 커밋 (보존용)
    pushd "$work_dir" > /dev/null
    git add -A 2>/dev/null || true
    git commit -m "experiment: ${branch_name} 완료" --allow-empty 2>/dev/null || true
    popd > /dev/null

    echo "  [${branch_name}] 완료"
}

# ============================================================
# ai-bouncer 설치 (stdin heredoc)
# ============================================================
install_ai_bouncer() {
    local work_dir=$1

    # stdin으로 자동 응답: 2(로컬), y(docs추적), 1(per-step)
    cd "$work_dir" && bash <(curl -sL https://raw.githubusercontent.com/kangraemin/ai-bouncer/main/install.sh) <<'INSTALL_EOF'
2
y
1
INSTALL_EOF

    echo "  ai-bouncer 설치 완료"
}

# ============================================================
# 메인 루프
# ============================================================
for run_num in $(seq "$START_RUN" "$END_RUN"); do
    if [ -z "$MODE_FILTER" ] || [ "$MODE_FILTER" = "with" ]; then
        run_single "with" "$run_num"
    fi

    if [ -z "$MODE_FILTER" ] || [ "$MODE_FILTER" = "without" ]; then
        run_single "without" "$run_num"
    fi
done

# ============================================================
# 통계 집계
# ============================================================
if ! $DRY_RUN; then
    echo ""
    echo "============================================================"
    echo "통계 집계 중..."
    echo "============================================================"
    python3 "$SCRIPT_DIR/aggregate-results.py" --results-dir "$RESULTS_DIR" || true
fi

echo ""
echo "============================================================"
echo "실험 완료!"
echo "  결과: $RESULTS_DIR"
echo "============================================================"
