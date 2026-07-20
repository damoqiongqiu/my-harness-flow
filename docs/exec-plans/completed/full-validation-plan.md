# demo-nextjs — my-harness-flow 全量能力验证计划

**日期**: 2026-07-20  
**项目**: demo-nextjs (Next.js 14)  
**Profile**: web  
**预计耗时**: 一轮完整验证约 30 分钟

## 已验证 ✅

| # | 能力 | 状态 |
|---|------|------|
| 1 | install --profile web | ✅ |
| 2 | start-task (Standard/Full) + exec-plan | ✅ |
| 3 | spec-driven-implementation | ✅ |
| 4 | quality-gate L1 (6 项) | ✅ |
| 5 | quality-gate L2 (5 端点) | ✅ |
| 6 | Jest 自动检测 + 单测 | ✅ |
| 7 | git-branch → git-commit → finish-task | ✅ |
| 8 | upgrade + profile 差异检测 | ✅ |
| 9 | Next.js build verify | ✅ |
| 10 | 32 → 1 commit squash | ✅ |

## 待验证 🔲

| 优先级 | # | 能力 | 验证方式 | 预期结果 |
|--------|---|------|---------|---------|
| P0 | 11 | uninstall + reinstall | 卸载后重新安装 | 无残留 + 重装正常 |
| P0 | 12 | L5 全量回归 | L1→L2→L3→L4→L5 | 0 FAIL |
| P1 | 13 | create-issue | 从对话创建 GitHub issue | issue 创建成功 |
| P1 | 14 | create-pr | 推分支后创建 PR | PR 关联 issue |
| P1 | 15 | session-start | 新会话恢复上下文 | 正确读 exec-plan |
| P1 | 16 | diagnose | 故意制造失败看诊断 | 归因正确 |
| P2 | 17 | bootstrap-issue-config | 生成 triage 配置 | CODEOWNERS + config |
| P2 | 18 | retrospect | 基于 work-journal 复盘 | 输出评估报告 |
| P2 | 19 | write-product-spec | 写完整 PRD | 含行为+验证标准 |
| P2 | 20 | resolve-merge-conflicts | 制造冲突后解决 | 冲突干净解决 |

## 不在验证范围

| 能力 | 原因 |
|------|------|
| mobile/backend profiles | 需要对应技术栈项目 |
| e2e-test (Playwright) | 需要浏览器环境 |
| review-pr-local | 需要 CI contracts |
| ci.yml (GitHub Actions) | 已在 harness 自身上验证 |

## 执行结果 (2026-07-20)

| # | 能力 | 结果 |
|---|------|------|
| 1-10 | 已验证 | ✅ 全部通过 |
| 11 | uninstall + reinstall | ✅ |
| 12 | L5 全量回归 | ✅ 4/4 PASS |
| 13 | create-issue | ⏸️ 无 gh CLI |
| 14 | create-pr | ⏸️ 无 gh CLI |
| 15 | session-start | 可测试 |
| 16 | diagnose | 可测试 |
| 17-20 | P2 项 | 低优 |
