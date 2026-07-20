#!/usr/bin/env bash
# L4 安全测试 — 硬编码密码扫描 + 品牌中性
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PASS=0 WARN=0 FAIL=0

pass() { PASS=$((PASS+1)); }
warn() { WARN=$((WARN+1)); echo "  [WARN] $1 — $2"; }
fail() { FAIL=$((FAIL+1)); echo "  [FAIL] $1 — $2"; }

echo "=== L4 安全测试 ==="
echo ""

# 1. 硬编码密钥/密码扫描
echo "--- 1. 硬编码密钥扫描 ---"
HITS=$(grep -rni 'password\s*=\s*["'"'"']' "$ROOT" \
  --include="*.py" --include="*.sh" --include="*.yaml" --include="*.yml" \
  --exclude-dir=.git --exclude-dir=.workbuddy --exclude-dir=deliverables \
  2>/dev/null | grep -v 'os.environ\|env\|ENV\|example\|placeholder\|PLACEHOLDER\|TODO\|template\|示例' || true)

if [ -z "$HITS" ]; then
  pass "无硬编码密码"
else
  CNT=$(echo "$HITS" | wc -l | tr -d ' ')
  fail "硬编码密码" "发现 $CNT 处疑似硬编码: $(echo "$HITS" | head -3)"
fi

# 2. API key / token 扫描
echo "--- 2. API key 扫描 ---"
HITS=$(grep -rni 'api_key\s*=\s*["'"'"']\|secret\s*=\s*["'"'"']\|token\s*=\s*["'"'"']' "$ROOT" \
  --include="*.py" --include="*.sh" --include="*.yaml" --include="*.yml" \
  --exclude-dir=.git --exclude-dir=.workbuddy --exclude-dir=deliverables \
  2>/dev/null | grep -v 'os.environ\|env\|ENV\|example\|placeholder\|PLACEHOLDER\|\$\|TODO\|template\|GITHUB_TOKEN\|OPENAI_API_KEY' || true)
if [ -z "$HITS" ]; then
  pass "无硬编码 API key"
else
  CNT=$(echo "$HITS" | wc -l | tr -d ' ')
  warn "API key" "发现 $CNT 处引用（如为模板说明则安全）"
fi

# 3. 品牌中性
echo "--- 3. 品牌中性 ---"
HITS=$(grep -rni 'superpowers\|obra\|humanlayer\|anthropic\|Terry-Mao\|AICodingFlow' "$ROOT" \
  --exclude-dir=.git --exclude-dir=.workbuddy --exclude-dir=deliverables --exclude-dir=.agents | grep -v README.md | grep -v CHANGELOG.md || true)
if [ -z "$HITS" ]; then
  pass "品牌中性"
else
  fail "品牌中性" "发现来源项目引用"
fi

echo ""
echo "结果: PASS=$PASS  WARN=$WARN  FAIL=$FAIL"
[ "$FAIL" -gt 0 ] && { echo "结论: FAIL"; exit 1; }
echo "结论: PASS"
