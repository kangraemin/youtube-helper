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

    # 2. with 모드: ai-bouncer 설치
    if [ "$mode" = "with" ]; then
        echo "  ai-bouncer 설치 중..."
        install_ai_bouncer "$work_dir"
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
# ai-bouncer 설치 (pexpect 없이 직접 실행)
# ============================================================
install_ai_bouncer() {
    local work_dir=$1

    # expect를 사용한 자동 설치
    # install.sh가 물어보는 질문들에 자동 응답
    expect -c "
        set timeout $INSTALL_TIMEOUT
        spawn bash -c \"cd '$work_dir' && bash <(curl -sL https://raw.githubusercontent.com/kangraemin/ai-bouncer/main/install.sh)\"

        # Q1: 설치 범위 선택 — 2) 로컬 (.claude/)
        expect {
            -re {선택.*\\\[1\\\]} { send \"2\r\" }
            timeout { }
        }

        # Q2: docs/ 폴더 git 추적 — y
        expect {
            -re {\\\(y/n\\\)} { send \"y\r\" }
            timeout { }
        }

        # Q3: 커밋 전략 — 1) per-step
        expect {
            -re {선택.*\\\[1\\\]} { send \"1\r\" }
            timeout { }
        }

        expect eof
    " 2>&1 | tail -5

    echo "  ai-bouncer 설치 완료 (또는 타임아웃)"
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
