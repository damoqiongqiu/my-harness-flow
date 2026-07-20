#!/usr/bin/env bash
# L1 冒烟测试 — my-harness-flow 框架自身验证
# 验证文档约定的核心命令链（见 AGENTS.md 第 6 节）
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PASS=0 FAIL=0

check() { local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then echo "  [PASS] $label"; PASS=$((PASS+1))
  else echo "  [FAIL] $label"; FAIL=$((FAIL+1)); fi; }

echo "=== L1 my-harness-flow 自身健康检查 ==="
echo ""

echo "1. 语法检查:"
check "bash -n my-harness-cli.sh" "bash -n $ROOT/my-harness-cli.sh"

echo ""
echo "2. 安装器帮助:"
check "version 命令正常" "$ROOT/my-harness-cli.sh version >/dev/null"
check "help 命令正常" "$ROOT/my-harness-cli.sh help >/dev/null"
check "dry-run 不报错" "TGT=\$(mktemp -d \"\${TMPDIR:-/tmp}/hf-l1-XXXXXX\") && $ROOT/my-harness-cli.sh install --target \"\$TGT\" --dry-run >/dev/null 2>&1; RC=\$?; rm -rf \"\$TGT\"; [ \$RC -eq 0 ]"

echo ""
echo "3. Python 编译:"
check "py_compile .github/scripts/*.py" "PYTHONPYCACHEPREFIX=\${TMPDIR:-/tmp}/hf-pycache python3 -m py_compile $ROOT/.github/scripts/*.py"

echo ""
echo "4. 品牌中性扫描:"
check "无来源项目关键词" "! grep -rni 'superpowers\|obra\|humanlayer\|anthropic\|Terry-Mao\|AICodingFlow' $ROOT --exclude-dir=.git --exclude-dir=.workbuddy --exclude-dir=deliverables --exclude-dir=.agents | grep -v README.md | grep -v CHANGELOG.md | grep -q ."

echo ""
echo "5. 关键文件完整性:"
check "VERSION 存在" "[ -f $ROOT/VERSION ]"
check "CHANGELOG.md 存在" "[ -f $ROOT/CHANGELOG.md ]"
check "AGENTS.md 存在" "[ -f $ROOT/AGENTS.md ]"
check "21 个核心技能" "[ \$(ls -d $ROOT/.agents/skills/*/ 2>/dev/null | wc -l) -eq 21 ]"

echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -gt 0 ] && { echo "结论: FAIL"; exit 1; }
echo "结论: PASS"
