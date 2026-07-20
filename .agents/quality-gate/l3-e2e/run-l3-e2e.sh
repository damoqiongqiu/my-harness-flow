#!/usr/bin/env bash
# L3 E2E 测试 — 全生命周期：install → upgrade → profile → uninstall
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PASS=0 FAIL=0 TMPDIR="${TMPDIR:-/tmp}"
TGT="$(mktemp -d "$TMPDIR/hf-l3-XXXXXX")"

pass() { PASS=$((PASS+1)); }
fail() { FAIL=$((FAIL+1)); echo "  [FAIL] $1 — $2"; }

echo "=== L3 全生命周期 E2E ==="
echo ""

# 1. 全新安装 + web profile
echo "--- 1. 安装 + web profile ---"
"$ROOT/my-harness-cli.sh" install --target "$TGT" --profile web --yes >/dev/null 2>&1 \
  && pass "install+web" || fail "install+web" "安装失败"

# 2. 确认产物
echo "--- 2. 产物验证 ---"
[ -f "$TGT/AGENTS.md" ] && pass "AGENTS.md" || fail "AGENTS.md" "缺失"
[ -f "$TGT/.agents/.harness-flow-manifest" ] && pass "manifest" || fail "manifest" "缺失"
[ -d "$TGT/.agents/quality-gate/scenarios" ] && pass "test-dir" || fail "test-dir" "缺失"
grep -q "profile: web" "$TGT/AGENTS.md" && pass "AGENTS-profile" || fail "AGENTS-profile" "未注入"

# 3. L1 自检
echo "--- 3. L1 自检 ---"
if bash "$TGT/.agents/quality-gate/l1-health-check.sh" >/dev/null 2>&1; then
  pass "L1-self-check"
else
  fail "L1-self-check" "自检未通过"
fi

# 4. 卸载
echo "--- 4. 卸载 ---"
"$ROOT/my-harness-cli.sh" uninstall --target "$TGT" --yes >/dev/null 2>&1 \
  && pass "uninstall" || fail "uninstall" "卸载失败"

# 5. 确认清理
echo "--- 5. 清理验证 ---"
[ ! -f "$TGT/.agents/.harness-flow-installed" ] && pass "marker-cleaned" || fail "marker-cleaned" "marker 残留"
[ -f "$TGT/AGENTS.md" ] && pass "AGENTS-kept" || fail "AGENTS-kept" "被误删"

rm -rf "$TGT"

echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -gt 0 ] && { echo "结论: FAIL"; exit 1; }
echo "结论: PASS"
