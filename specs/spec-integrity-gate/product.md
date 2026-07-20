# Spec 完整性门禁 — 产品 Spec

**状态**: ✅ 已交付 | **创建**: 2026-07-20

## 问题
Agent 跳过 spec 直接修改代码是最常见的质量滑坡起点。之前仅 Full 档检查 spec，Light/Standard 任务可以无 spec 直接实现。开发者也看不到任何记录。

## 方案
L1 §5 Spec 完整性检查——任何活跃 exec-plan 都必须有对应 `specs/<topic>/`

## 行为
- 活跃 exec-plan 存在 → 检查 `specs/<topic>/`
- 有 spec → [PASS]
- 缺 spec → [WARN] "请先创建 specs/<topic>/product.md"
- 无 exec-plan → [SKIP]

## 验收
- [x] 有 spec → PASS
- [x] 缺 spec → WARN
- [x] 空 active/ → SKIP
- [x] 三个 profile 全部覆盖
- [x] specs/README 模板更新："不需要 spec" → "Light 至少 product.md"
