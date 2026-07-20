#!/usr/bin/env bash
# L1 冒烟测试 — 前端基础设施健康检查
set -euo pipefail
PASS=0 FAIL=0 SKIP=0

check() { local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then echo "  [PASS] $label"; PASS=$((PASS+1))
  else echo "  [FAIL] $label"; FAIL=$((FAIL+1)); fi; }

echo "=== L1 前端健康检查 ==="
echo ""

echo "1. 运行时环境:"
check "node 可用" 'command -v node'
check "npm/yarn/pnpm 可用" 'command -v npm || command -v yarn || command -v pnpm'

echo ""
echo "2. 依赖完整性:"
check "node_modules 存在" '[ -d node_modules ]'

echo ""
echo "3. 代码质量:"
check "TypeScript 类型检查" 'npx tsc --noEmit'
if [ -x node_modules/.bin/eslint ]; then
  check "ESLint 零错误" 'npx eslint . --max-warnings=0'
else
  echo "  [SKIP] ESLint 未安装"
  SKIP=$((SKIP+1))
fi
if [ -x node_modules/.bin/jest ]; then
  check "Jest 单测通过" 'npx jest --passWithNoTests'
else
  echo "  [SKIP] Jest 未安装"
  SKIP=$((SKIP+1))
fi

echo ""
echo "5. Spec 完整性:"
if [ -d docs/exec-plans/active ] && ls docs/exec-plans/active/*.md >/dev/null 2>&1; then
  for plan in docs/exec-plans/active/*.md; do
    topic="$(basename "$plan" .md)"
    if [ -d "specs/$topic" ]; then
      echo "  [PASS] $topic → specs/$topic/"
    else
      echo "  [WARN] $topic 缺 spec——请先创建 specs/$topic/product.md"
    fi
  done
else
  echo "  [SKIP] 无活跃 exec-plan"
fi

echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"
[ "$FAIL" -gt 0 ] && { echo "结论: FAIL"; exit 1; }
echo "结论: PASS"
