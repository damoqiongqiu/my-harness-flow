# 看板视图 — 拖拽式任务管理

**档位**: Full  
**分支**: feat/kanban-demo  
**阶段**: 实现中  
**specs**: docs/specs/kanban-board/spec.md  
**创建时间**: 2026-07-19

## 定档分析

| 维度 | 判定 | 结论 |
|------|------|------|
| 风险域 | 一般逻辑（UI + 无状态 API） | Standard |
| 影响面 | 3 API + 2 页面 + 数据模型 + 组件库 | **→ Full**（跨模块） |
| 行为变更 | 新增行为（task 模型增加 status 字段） | Standard |
| 规模 | ~400 行 | **→ Full** |

**结论: Full 档** — 影响面 + 规模均命中 Full，建议走 spec 驱动。

## 改动清单

| # | 类别 | 文件 | 内容 |
|---|------|------|------|
| 1 | feat | src/lib/types.ts | Task 类型扩展 (status + updatedAt) |
| 2 | feat | src/app/api/tasks/route.ts | GET 支持 status 筛选 + PATCH 批量更新 |
| 3 | feat | src/app/board/page.tsx | 看板页面（三列拖拽） |
| 4 | feat | src/app/board/kanban.tsx | KanbanBoard 组件 |
| 5 | test | l2-integration.sh | 新增看板 API 测试 |

## 验证计划

- [ ] spec 驱动：写 spec → 确认 → 实现
- [ ] L1 冒烟 5/5 (tsc/eslint)
- [ ] L2 单元 (API 契约 + 批量更新)
- [ ] 构建通过
- [ ] git-commit + finish-task 归档
