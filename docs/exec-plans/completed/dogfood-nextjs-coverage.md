# demo-nextjs 全面覆盖性测试 — harness 能力清单验证

**档位**: Full  
**分支**: feat/dogfood-nextjs  
**阶段**: 实现中  
**目标**: 用 demo-nextjs 项目系统性验证 harness 的核心能力链条

## 验证清单

| # | SKILL | 验证内容 | 预期 |
|---|-------|---------|------|
| 1 | start-task | 四维定档 + 创建 exec-plan | Full 档 |
| 2 | git-branch | 在 demo 项目创建特性分支 | feat/task-complete |
| 3 | implement | 实现任务完成 + 搜索 + 测试 | 3 个新功能 |
| 4 | L1 冒烟 | tsc/eslint/build 全部通过 | 0 FAIL |
| 5 | L2 单元 | API 契约 CRUD + 新端点 | 0 FAIL |
| 6 | build-verify (web) | npm run build 产物验证 | 0 FAIL |
| 7 | git-commit | 按规范精准 stage + commit | feat(tasks): ... |
| 8 | finish-task | exec-plan 归档 + work-journal | 完成 |
