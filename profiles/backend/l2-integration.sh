#!/usr/bin/env bash
# L2 单元测试 — 服务端 API + DB 链路
# 用法: ./l2-integration.sh [--module <模块名>]
set -euo pipefail

PASS=0 FAIL=0
pass() { PASS=$((PASS+1)); }
fail() { FAIL=$((FAIL+1)); echo "  [FAIL] $1 — $2"; }

echo "=== L2 服务端单元测试 ==="
echo ""

# ── 按项目实际情况注册 ──────────────────────────────
MODULES=(
  # "user-service:test_user_service"
  # "order-service:test_order_service"
)

if [ ${#MODULES[@]} -eq 0 ]; then
  echo "结果: SKIP（未注册模块，请编辑本脚本的 MODULES 数组）"
  exit 0
fi

MODULE_FILTER="${1:-}"
for entry in "${MODULES[@]}"; do
  name="${entry%%:*}"
  [ -n "$MODULE_FILTER" ] && [ "$name" != "$MODULE_FILTER" ] && continue
  echo "--- $name ---"
  "${entry##*:}" || true
done

total=$((PASS + FAIL))
rate=$((PASS * 100 / (total + 1)))
echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL  通过率=${rate}%"
[ "$rate" -ge 90 ] && { echo "结论: PASS"; exit 0; }
echo "结论: FAIL"; exit 1
