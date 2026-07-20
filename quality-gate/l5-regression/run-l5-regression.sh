#!/usr/bin/env bash
# L5 全量回归 — my-harness-flow 发布前最终验证
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0 FAIL=0

run() {
  local label="$1" script="$2"
  echo "=== $label ==="
  if [ ! -f "$script" ]; then
    echo "  [SKIP] 脚本不存在: $script"
    return
  fi
  if bash "$script"; then
    echo "  [PASS] $label"
    PASS=$((PASS+1))
  else
    echo "  [FAIL] $label"
    FAIL=$((FAIL+1))
  fi
  echo ""
}

run "L1 冒烟"   "$SCRIPT_DIR/../l1-smoke/health-check.sh"
run "L2 单元"   "$SCRIPT_DIR/../l2-integration/run-l2-integration.sh"
run "L3 E2E"    "$SCRIPT_DIR/../l3-e2e/run-l3-e2e.sh"
run "L4 安全"   "$SCRIPT_DIR/../l4-security/run-l4-security.sh"

echo "结果: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -gt 0 ] && { echo "结论: FAIL（禁止发布）"; exit 1; }
echo "结论: PASS（可发布）"
