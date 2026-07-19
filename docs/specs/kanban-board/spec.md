# 看板视图 — 产品 Spec

**关联 exec-plan**: docs/exec-plans/active/kanban-board.md  
**创建时间**: 2026-07-19  
**状态**: 草稿 → 确认中

## 1. 用户故事

作为用户，我希望在任务列表之外有一个看板视图，将任务按状态（待办 / 进行中 / 已完成）分列展示，以便直观了解项目进度。

## 2. 功能描述

### 2.1 数据模型变更

Task 类型增加字段：
- `status`: `"todo"` | `"doing"` | `"done"`（默认 `"todo"`）
- `updatedAt`: ISO 字符串（每次状态变更更新）

现有 `done: boolean` 字段保留兼容（只读）。

### 2.2 API 变更

| 端点 | 变更 |
|------|------|
| `GET /api/tasks` | 新增 `?status=todo\|doing\|done` 可选筛选参数 |
| `PATCH /api/tasks?id=` | status 参数支持 `?status=todo\|doing\|done`；404 处理保持 |
| `POST /api/tasks` | 新增 `status` 可选字段（默认 todo） |

### 2.3 看板页面 `/board`

- 三列布局：待办（todo）/ 进行中（doing）/ 已完成（done）
- 每列显示任务卡片（标题 + 切换状态按钮）
- 点击按钮将任务移到下一列（禁用状态圆圈的拖拽——轻量实现）
- 空列显示提示文字

## 3. 非功能需求

- 页面首次加载 < 2s
- API 批量操作幂等
- 三列布局移动端可纵向滚动

## 4. 边界场景

| 场景 | 预期行为 |
|------|---------|
| 空看板 | 三列均显示「暂无任务」 |
| status=invalid | API 返回 400 |
| 切换不存在的任务 | 返回 404 |

## 5. 验收标准

- [ ] `GET /api/tasks?status=doing` 返回正确筛选结果
- [ ] `PATCH /api/tasks?id=1&status=done` 成功更新
- [ ] `/board` 页面三列正确渲染
- [ ] L1 冒烟 5/5 + L2 单元新增 4 项测试
- [ ] 构建成功
