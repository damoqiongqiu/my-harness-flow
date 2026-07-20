#!/usr/bin/env bash
# L2 单元测试 — 安装器全功能验证
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PASS=0 FAIL=0 TMPDIR="${TMPDIR:-/tmp}"

pass() { PASS=$((PASS+1)); }
fail() { FAIL=$((FAIL+1)); echo "  [FAIL] $1 — $2"; }

echo "=== L2 安装器验证 ==="
echo ""

# ── test 1: 全新安装 ────────────────────────────────
echo "--- 1. 全新安装 ---"
TGT="$(mktemp -d "$TMPDIR/hf-l2-XXXXXX")"
if "$ROOT/my-harness-cli.sh" install --target "$TGT" --yes >/dev/null 2>&1; then
  [ -f "$TGT/.agents/.harness-flow-installed" ] && pass "install" || fail "install" "marker 缺失"
else
  fail "install" "安装失败"
fi

# ── test 2: 幂等重装（输出应含"完全一致"或"无需同步"） ──
echo "--- 2. 幂等重装 ---"
OUT="$("$ROOT/my-harness-cli.sh" install --target "$TGT" --yes 2>&1 || true)"
if echo "$OUT" | grep -qF "完全一致" || echo "$OUT" | grep -qF "无需同步"; then
  pass "idempotent"
else
  fail "idempotent" "重复安装未短路: $(echo "$OUT" | head -1)"
fi

# ── test 3: dry-run ──────────────────────────────────
echo "--- 3. dry-run ---"
"$ROOT/my-harness-cli.sh" install --target "$TGT" --dry-run >/dev/null 2>&1 && pass "dry-run" || fail "dry-run" "失败"

# ── test 4: status ───────────────────────────────────
echo "--- 4. status ---"
STATUS="$("$ROOT/my-harness-cli.sh" status --target "$TGT" 2>&1 || true)"
if echo "$STATUS" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+'; then
  pass "status"
else
  fail "status" "版本信息缺失: $(echo "$STATUS" | head -1)"
fi

# ── test 5: version ──────────────────────────────────
echo "--- 5. version ---"
"$ROOT/my-harness-cli.sh" version 2>&1 | grep -q 'my-harness-flow' && pass "version" || fail "version" "异常"

# ── test 6: upgrade ──────────────────────────────────
echo "--- 6. upgrade ---"
"$ROOT/my-harness-cli.sh" upgrade --target "$TGT" --yes >/dev/null 2>&1 && pass "upgrade" || fail "upgrade" "失败"

# ── test 7: 模板差异 ─────────────────────────────────
echo "--- 7. 模板差异检测 ---"
echo "# user modified" >> "$TGT/.agents/quality-gate/l1-smoke/health-check.sh"
OUT="$("$ROOT/my-harness-cli.sh" install --target "$TGT" --yes 2>&1 || true)"
echo "$OUT" | grep -q "检测到.*模板.*更新" && pass "template-diff" || fail "template-diff" "未检测到"

# ── test 8: profile ──────────────────────────────────
echo "--- 8. profile 安装 ---"
OUT="$("$ROOT/my-harness-cli.sh" install --target "$TGT" --yes --profile backend 2>&1 || true)"
echo "$OUT" | grep -q "profile 'backend'" && pass "profile-install" || fail "profile-install" "未生效"

# ── test 9: uninstall ────────────────────────────────
echo "--- 9. uninstall ---"
"$ROOT/my-harness-cli.sh" uninstall --target "$TGT" --yes >/dev/null 2>&1 \
  && [ ! -f "$TGT/.agents/.harness-flow-installed" ] \
  && pass "uninstall" || fail "uninstall" "失败"
rm -rf "$TGT"

echo ""
total=$((PASS + FAIL))
rate=$((PASS * 100 / total))
echo "结果: PASS=$PASS  FAIL=$FAIL  通过率=${rate}%"
[ "$rate" -ge 90 ] && { echo "结论: PASS"; exit 0; }
echo "结论: FAIL"; exit 1
