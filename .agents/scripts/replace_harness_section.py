#!/usr/bin/env python3
"""原地替换 AGENTS.md 中 harness 标记段内容"""
import sys, re

user = open(sys.argv[1]).read()
harness = open(sys.argv[2]).read()

# 原地替换：begin 到 end 之间的内容
result = re.sub(
    r'<!-- my-harness-flow: begin -->.*?<!-- my-harness-flow: end -->',
    harness.strip(),
    user, count=1, flags=re.DOTALL
)
# 清理残留
result = re.sub(r'\s*---\s*\n\s*<!-- 以下为用户自定义内容.*?-->\s*\n*', '\n', result)
open(sys.argv[1], 'w').write(result)
