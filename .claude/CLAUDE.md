# --- ai-bouncer-rule start ---
## ai-bouncer
코드 수정 / 기능 구현 / 파일 변경 / 버그 수정 등 개발 작업 시 반드시 `/dev-bounce` 스킬을 먼저 호출할 것.
# --- ai-bouncer-rule end ---

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
