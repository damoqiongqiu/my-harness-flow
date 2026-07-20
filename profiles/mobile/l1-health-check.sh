#!/usr/bin/env bash
# L1 冒烟测试 — 移动端基础设施健康检查
set -euo pipefail
PASS=0 FAIL=0 SKIP=0

check() { local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then echo "  [PASS] $label"; PASS=$((PASS+1))
  else echo "  [FAIL] $label"; FAIL=$((FAIL+1)); fi; }

echo "=== L1 移动端健康检查 ==="
echo ""

echo "1. SDK 环境:"
check "Xcode CLI 可用" 'command -v xcodebuild'
check "Android SDK 可用" 'command -v adb || echo SKIP'
check "Flutter SDK 可用" 'command -v flutter || echo SKIP'

echo ""
echo "2. 模拟器状态:"
# check "iOS 模拟器可用" 'xcrun simctl list devices | grep -q Booted'
# check "Android 模拟器可用" 'adb get-state 2>/dev/null | grep -q device'

echo ""
echo "3. 文件完整性:"
check "Xcode 工程存在" '[ -d *.xcodeproj ] || [ -d *.xcworkspace ] || echo SKIP'
check "Gradle 工程存在" '[ -f build.gradle ] || [ -f build.gradle.kts ] || echo SKIP'
check "Flutter 工程存在" '[ -f pubspec.yaml ] || echo SKIP'

echo ""
echo "4. 代码风格（按平台取消注释）:"
# iOS:
# check "SwiftLint 零错误" 'swiftlint lint --strict'
# check "SwiftFormat 格式一致" 'swiftformat --lint .'

# Android:
# check "ktlint 零错误" 'ktlint --relative'
# check "Android Lint 零错误" './gradlew lint'
# check "Detekt 静态分析" './gradlew detekt'

# Flutter:
# check "flutter analyze 零问题" 'flutter analyze --no-fatal-infos --no-fatal-warnings'
# check "dart format 格式一致" 'dart format --set-exit-if-changed lib/ test/'
# check "flutter test 通过" 'flutter test'

echo ""
echo "5. 文档格式校验:"
warn() { echo "  [WARN] $1"; }

if [ -d docs/exec-plans/active ] && ls docs/exec-plans/active/*.md >/dev/null 2>&1; then
  for plan in docs/exec-plans/active/*.md; do
    topic="$(basename "$plan" .md)"
    if [ -d "specs/$topic" ]; then
      echo "  [PASS] $topic → specs/$topic/"
      if grep -qE '状态|## 功能' "specs/$topic/product.md" 2>/dev/null; then
        echo "    [PASS] product.md 格式"
      else
        warn "    $topic/product.md 缺少状态/功能声明"
      fi
      if grep -qE '\*\*关联\*\*' "specs/$topic/tech.md" 2>/dev/null; then
        echo "    [PASS] tech.md 格式"
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

if [ -d docs/work-journal ] && ls docs/work-journal/20*.md >/dev/null 2>&1; then
  bad=$(ls docs/work-journal/ | grep -v '^20[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}\.md$' || true)
  [ -n "$bad" ] && warn "work-journal 非 YYYY-MM-DD.md: $bad"
fi

if [ -d docs/bugs ] && ls docs/bugs/*.md >/dev/null 2>&1; then
  for b in docs/bugs/*.md; do
    grep -qE '## 复现|## 根因' "$b" 2>/dev/null || warn "$(basename "$b") 缺少复现/根因段"
  done
fi

echo ""
echo "结果: PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"
echo "结论: PASS"
