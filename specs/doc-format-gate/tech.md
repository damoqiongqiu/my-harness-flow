# 文档格式校验 — 技术 Spec

**关联**: specs/doc-format-gate/product.md

## 实现
- L1 三个 profile 的 §5 Spec 完整性段扩展为 "文档格式校验"
- 每项检查用 grep -q 匹配特征行，不阻塞 PASS
- 新增 `format_check()` 辅助函数：WARN 但不计 FAIL

## 匹配规则
```bash
# product.md: 状态行或 ## 功能
grep -qE '状态|## 功能' specs/<topic>/product.md

# tech.md: 关联行
grep -qE '\*\*关联\*\*' specs/<topic>/tech.md

# work-journal: 日期命名
ls docs/work-journal/ | grep -qE '^20[0-9]{2}-[0-9]{2}-[0-9]{2}\.md$'

# bug: 模板字段
grep -lE '## 复现|## 根因' docs/bugs/*.md
```
