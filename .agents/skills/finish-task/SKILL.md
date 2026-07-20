---
name: finish-task
description: 收尾当前任务：基于真实 diff 精确暂存并提交（禁 git add . 与 --no-verify），推送分支并创建 PR/MR（GitHub/GitLab 自适应，无 remote 则跳过），将 exec-plan 从 active/ 移至 completed/ 并写工作日志交付行。
---

# finish-task

**目标项目路径规则**：exec-plan 移动（`active/` → `completed/`）和 work-journal 写入均操作**目标项目**的 `docs/`，非 framework 项目。如果当前工作目录在 harness framework，先确定目标项目路径再操作。

收尾当前任务的改动：精确提交 + 推送 + 创建 PR + 留痕。

## 1. 流程

0. **确认 quality-gate 已通过**。未通过 → 调 `diagnose` 归因（不直接回 quality-gate），确认根因并修复后再重跑 quality-gate，通过后继续。
1. 用 `git-commit` 精确 stage 变更文件（格式见 `AGENTS.md` commit 规范，禁止 git add .）。
2. 用 `git-push` 推送分支（禁止 force push main）。
3. 用 `create-pr` 创建 PR（描述含 summary + 验证证据 + issue 链接 + 无明文密码）。
3.5 **合并后校验（MUST）**：若 PR 被 squash merge：
   - **等待 GitHub 落盘**：`gh pr view <N> --repo <owner/repo> --json mergedAt` 直到返回非空时间戳
   - **pull 后校验**：`git pull origin main` 后确认关键文件存在：
     ```bash
     # 确认 spec 文件未丢失（squash merge 常见的幽灵漏洞）
     for spec_dir in $(find docs/exec-plans/completed -name "*.md" -maxdepth 1 2>/dev/null); do
       topic=$(basename "$spec_dir" .md)
       [ -d "specs/$topic" ] || echo "⚠ 缺失 specs/$topic/ ——请从分支恢复"
     done
     bash .agents/quality-gate/l1-health-check.sh | grep "Spec 完整性"
     ```
   - **缺失则恢复**：`git checkout <branch-sha> -- specs/<topic>/` 然后追加 commit
4. 写 `docs/work-journal/YYYY-MM-DD.md` 一行交付记录。
5. 把 `docs/exec-plans/active/<任务简称>.md` 移到 `docs/exec-plans/completed/`，标注完成时间。
6. 若本次改动涉及生成物（schema 导出、codegen、文档编译等）且项目提供了刷新脚本，运行对应脚本并把产物一并提交（脚本位置见项目 `AGENTS.md`；没有则跳过）。

## 2. 禁区

- 禁止 `git add .`。
- 禁止 force push `main`。
- 禁止提交含明文密码的代码。

## 3. 输出

- commit hash + PR 链接 + work-journal 条目。
