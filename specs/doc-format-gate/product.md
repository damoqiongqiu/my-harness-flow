# 文档格式校验 — 产品 Spec

**状态**: ✅ 已交付 | **创建**: 2026-07-20

## 问题
spec gate 只查目录存在，不查格式。用户写 `specs/foo/readme.md`、`work-journal/log.txt`、bug 不按模板，技能读不到关键信息但不报错。

## 方案
L1 §5 文档格式校验（WARN 不阻塞）

| 文档 | 检查项 |
|------|--------|
| `specs/<topic>/product.md` | 有 `**状态**` 或 `## 功能` 标题 |
| `specs/<topic>/tech.md` | 有 `**关联**` 行 |
| `docs/work-journal/YYYY-MM-DD.md` | 文件名匹配 `20[0-9]{2}-[0-9]{2}-[0-9]{2}.md` |
| `docs/bugs/*.md` | 有 `## 复现步骤` 或 `## 根因` 标题 |

## 验收
- [x] 合规文档 → PASS
- [x] 缺关键字段 → WARN
- [x] 不阻塞 L1 其他检查
