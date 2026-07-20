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
echo "5. 文档格式校验:"
warn() { echo "  [WARN] $1"; }

# 5a. Spec 完整性
if [ -d docs/exec-plans/active ] && ls docs/exec-plans/active/*.md >/dev/null 2>&1; then
  for plan in docs/exec-plans/active/*.md; do
    topic="$(basename "$plan" .md)"
    if [ -d "specs/$topic" ]; then
      echo "  [PASS] $topic → specs/$topic/"
      # 格式检查
      if grep -qE '状态|## 功能' "specs/$topic/product.md" 2>/dev/null; then
        echo "    [PASS] product.md 格式"
      else
        warn "    $topic/product.md 缺少状态/功能声明"
      fi
      if grep -qE '\*\*关联\*\*' "specs/$topic/tech.md" 2>/dev/null; then
        echo "    [PASS] tech.md 格式（有关联声明）"
      else
        warn "    $topic/tech.md 缺少 **关联** 声明"
      fi
    else
      warn "  $topic 缺 spec——请先创建 specs/$topic/product.md"
    fi
  done
else
  echo "  [SKIP] 无活跃 exec-plan"
fi

# 5b. Work-journal 命名
if [ -d docs/work-journal ] && ls docs/work-journal/20*.md >/dev/null 2>&1; then
  bad=$(ls docs/work-journal/ | grep -v '^20[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}\.md$' || true)
  if [ -n "$bad" ]; then
    warn "work-journal 文件未按 YYYY-MM-DD.md 命名: $bad"
  fi
fi

# 5c. Bug 模板
if [ -d docs/bugs ] && ls docs/bugs/*.md >/dev/null 2>&1; then
  for b in docs/bugs/*.md; do
    if grep -qE '## 复现|## 根因' "$b" 2>/dev/null; then :; else
      warn "$(basename "$b") 缺少 '复现步骤' 或 '根因' 段"
    fi
  done
fi

echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"
[ "$FAIL" -gt 0 ] && { echo "结论: FAIL"; exit 1; }
echo "结论: PASS"
