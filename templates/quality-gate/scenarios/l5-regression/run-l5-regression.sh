#!/usr/bin/env bash
# L5 全量回归测试 — 发布前最终验证
#
# 约定：
#   - 0 失败 → exit 0（PASS，允许发布）
#   - 有失败 → exit 1（FAIL，阻塞发布）
#   - 串联 L1-L4，不允许跳过任何层
#
# 实现方式：按项目实际情况串联各层脚本，每层退出码非 0 即为失败。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PASS=0 FAIL=0 SKIP=0

run_layer() {
  local label="$1" script="$2"
  echo "--- $label ---"
  if [ ! -f "$script" ]; then
    echo "  [SKIP] 脚本不存在: $script"
    SKIP=$((SKIP + 1))
    return
  fi
  if bash "$script"; then
    echo "  [PASS] $label"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $label"
    FAIL=$((FAIL + 1))
  fi
  echo ""
}

echo "=== L5 全量回归 ==="
echo ""

# ── 串联各层验证 ────────────────────────────────────

# 按项目实际情况调整脚本路径
run_layer "L1 冒烟"   "$SCRIPT_DIR/../l1-smoke/health-check.sh"
run_layer "L2 单元"   "$SCRIPT_DIR/../l2-integration/run-l2-integration.sh"
run_layer "L3 E2E"    "$SCRIPT_DIR/../l3-e2e/run-l3-e2e.sh"
run_layer "L4 安全"   "$SCRIPT_DIR/../l4-security/run-l4-security.sh"

# ── 项目特定检查（按需添加）─────────────────────────

# echo "--- 覆盖率 ---"
# # 检查代码覆盖率阈值
# # ...

# echo "--- 依赖审计 ---"
# # npm audit / pip audit / cargo audit
# # ...

echo "结果: PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"

if [ "$FAIL" -gt 0 ]; then
  echo "结论: FAIL（$FAIL 层验证未通过，禁止发布）"
  exit 1
else
  echo "结论: PASS（可发布）"
  exit 0
fi
