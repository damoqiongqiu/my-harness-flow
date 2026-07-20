#!/usr/bin/env bash
# L1 冒烟测试 — 基础设施 + 服务健康检查
#
# 约定：
#   - 全部通过 → exit 0（PASS）
#   - 任一失败 → exit 1（FAIL）
#   - 不可用的检查（如 Docker 未安装）→ 输出 SKIP 不算失败
#   - 每项检查输出 [PASS] / [FAIL] / [SKIP] 前缀
#
# 按项目实际情况实现以下检查分类，未实现的删除对应分类即可。

set -euo pipefail

PASS=0 FAIL=0 SKIP=0

check() {
  local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  [PASS] $label"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $label"
    FAIL=$((FAIL + 1))
  fi
}

skip_if_missing() {
  local label="$1" dep="$2"
  if command -v "$dep" >/dev/null 2>&1; then
    echo "  [SKIP] $label（$dep 不可用）"
    SKIP=$((SKIP + 1))
    return 0
  fi
  return 1
}

echo "=== L1 健康检查 ==="
echo ""

# ── 1. 环境变量检查 ──────────────────────────────────
echo "1. 环境变量:"
# check "NODE_ENV 已设置" '[ -n "${NODE_ENV:-}" ]'
# check "DATABASE_URL 已设置" '[ -n "${DATABASE_URL:-}" ]'

# ── 2. 依赖工具检查 ──────────────────────────────────
echo "2. 依赖工具:"
check "git 可用" 'command -v git'
# check "node >= 18" 'node -e "process.exit(+(process.version.slice(1).split(\".\")[0]) >= 18 ? 0 : 1)"'
# check "python3 可用" 'command -v python3'

# ── 3. 文件完整性检查 ─────────────────────────────────
echo "3. 文件完整性:"
check "AGENTS.md 存在" '[ -f AGENTS.md ]'
check ".gitignore 存在" '[ -f .gitignore ]'
# check "package.json 存在" '[ -f package.json ]'

# ── 4. 服务可达性检查（按项目实际情况）───────────────
echo "4. 服务可达性:"
# check "MySQL 可达" 'mysqladmin ping -h localhost --silent'
# check "Redis 可达" 'redis-cli ping'
# check "API /health 端点" 'curl -sf http://localhost:3000/health'

echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"

if [ "$FAIL" -gt 0 ]; then
  echo "结论: FAIL（$FAIL 项检查未通过）"
  exit 1
else
  echo "结论: PASS"
  exit 0
fi
