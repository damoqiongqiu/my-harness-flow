# 文档地图（SKILL → 目录映射）

| 目录 | 写入者 | 读取者 |
|------|--------|--------|
| `docs/plan/`（context.yaml / checklist.md） | 人工维护 | `session-start` |
| `docs/exec-plans/active/` | `start-task` | `session-start`（跨会话恢复） |
| `docs/exec-plans/completed/` | `finish-task` 归档 | 复盘查阅 |
| `docs/work-journal/` | `finish-task` 追加 | `retrospect`（证据复盘） |
| `docs/bugs/` | `diagnose`（确认代码 Bug 后） | `session-start`（风险提示） |
| `specs/` | `write-product-spec` / `write-tech-spec` | `spec-driven-implementation` / `start-task` |
