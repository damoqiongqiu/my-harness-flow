#!/usr/bin/env bash
# 重整 AGENTS.md 中所有 ## 标题的序号（0, 1, 2, ...）
set -euo pipefail

file="${1:?usage: $0 <AGENTS.md>}"
[ -f "$file" ] || exit 0

# 重整全文件所有 ## 标题的序号（0, 1, 2, ...）
awk '
  BEGIN { c = 0 }
  /^## / { sub(/^## ([0-9]+\. )?/, sprintf("## %d. ", c++)) }
  { print }
' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
