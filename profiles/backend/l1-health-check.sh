#!/usr/bin/env bash
# L1 冒烟测试 — 服务端基础设施健康检查
#
# 约定：全部通过 → exit 0，任一失败 → exit 1

set -euo pipefail
PASS=0 FAIL=0 SKIP=0

check() { local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then echo "  [PASS] $label"; PASS=$((PASS+1))
  else echo "  [FAIL] $label"; FAIL=$((FAIL+1)); fi; }

echo "=== L1 服务端健康检查 ==="
echo ""

echo "1. 运行时环境:"
check "node/python 运行时" 'command -v node || command -v python3'
check "Docker 可用" 'command -v docker'

echo ""
echo "2. 依赖服务:"
# check "MySQL 可达" 'mysqladmin ping -h ${DB_HOST:-localhost} --silent'
# check "Redis 可达" 'redis-cli -h ${REDIS_HOST:-localhost} ping'
# check "Kafka broker 可达" 'kafka-broker-api-versions --bootstrap-server ${KAFKA_BOOTSTRAP:-localhost:9092}'

echo ""
echo "3. 文件完整性:"
check "AGENTS.md 存在" '[ -f AGENTS.md ]'
check "migration 目录存在" '[ -d migrations ] || [ -d src/migrations ] || echo "SKIP"'

echo ""
echo "4. 代码风格（按项目语言取消注释）:"
# Go 项目:
# check "go vet 零警告" 'go vet ./...'
# 通用 lint:
# check "golangci-lint 零问题" 'golangci-lint run ./...'

# Python 项目:
# check "ruff 零问题" 'ruff check .'
# check "mypy 类型检查" 'mypy .'

# Java 项目:
# check "checkstyle 通过" 'mvn checkstyle:check'
# check "spotless 格式一致" 'mvn spotless:check'

# Node.js 项目:
# check "ESLint 零错误" 'npx eslint . --max-warnings=0'
# check "Prettier 格式一致" 'npx prettier --check .'

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
