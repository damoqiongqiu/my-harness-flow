#!/usr/bin/env bash
# 重整 AGENTS.md 中所有 ## 标题的序号（0, 1, 2, ...）
set -euo pipefail

file="${1:?usage: $0 <AGENTS.md>}"
[ -f "$file" ] || exit 0

# 在 harness 标记段内重整序号
awk '
  BEGIN { c = 0 }
  /<!-- my-harness-flow: end -->/ { in_harness = 0 }
  in_harness && /^## / {
    sub(/^## ([0-9]+\. )?/, sprintf("## %d. ", c++))
  }
  /<!-- my-harness-flow: begin -->/ { in_harness = 1 }
  { print }
' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
