#!/usr/bin/env bash
# L2 单元测试 — 单模块单元 / 单服务 API 链路
#
# 用法:
#   ./run-l2-integration.sh                          # 全部模块
#   ./run-l2-integration.sh --module <模块名>         # 单模块
#   ./run-l2-integration.sh --module <模块名> --verbose
#
# 约定：
#   - 通过率 ≥ 90% → exit 0（PASS）
#   - 通过率 < 90% → exit 1（FAIL）
#   - 退出码反映测试结果，供 quality-gate 判断
#
# 实现方式：按模块写 test_<module>() 函数，在本文件末尾的 MODULES 数组注册。

set -euo pipefail

VERBOSE=false
SELECTED_MODULE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --module) SELECTED_MODULE="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    *) echo "未知参数: $1"; exit 2 ;;
  esac
done

PASS=0 FAIL=0

pass() { PASS=$((PASS + 1)); $VERBOSE && echo "  [PASS] $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1 - $2"; }

# ── 模块测试函数（按项目实际情况实现）──────────────

# test_user_auth() {
#   echo "--- user-auth ---"
#   # 示例：curl API 并断言
#   local resp
#   resp="$(curl -sf http://localhost:3000/api/health || true)"
#   if [ -n "$resp" ]; then
#     pass "health 端点响应"
#   else
#     fail "health 端点响应" "无响应"
#   fi
# }

# test_order_service() {
#   echo "--- order-service ---"
#   # ...
# }

# ── 模块注册 ─────────────────────────────────────────

# 按项目实际情况注册模块，格式: "模块名:测试函数"
MODULES=(
  # "user-auth:test_user_auth"
  # "order-service:test_order_service"
)

# ── 运行 ─────────────────────────────────────────────

echo "=== L2 单元测试 ==="
echo ""

if [ ${#MODULES[@]} -eq 0 ]; then
  echo "结果: SKIP（未注册任何测试模块，请在脚本末尾的 MODULES 数组中注册）"
  echo "提示: 按项目实际情况实现各模块的 test_<module>() 函数。"
  exit 0
fi

for entry in "${MODULES[@]}"; do
  module="${entry%%:*}"
  func="${entry##*:}"
  if [ -n "$SELECTED_MODULE" ] && [ "$module" != "$SELECTED_MODULE" ]; then
    continue
  fi
  $func
done

total=$((PASS + FAIL))
if [ "$total" -eq 0 ]; then
  echo "结果: SKIP（无匹配模块）"
  exit 0
fi

rate=$((PASS * 100 / total))
echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL  通过率=${rate}%"

if [ "$rate" -ge 90 ]; then
  echo "结论: PASS"
  exit 0
else
  echo "结论: FAIL（通过率 $rate% < 90%）"
  exit 1
fi
