---
name: git-worktree
description: 创建隔离的 Git 工作树，用于并行分支开发，包含高效命名、基准选择和安全性检查。
---

# git-worktree

创建一个独立的 worktree，不干扰当前 worktree，然后使用新目录进行后续 Codex 工具调用。这不会改变用户已有的 shell；报告 `cd` 命令。

## 1. 命名和路径

- 分支名遵循 `git-branch`。
- 关联 issue：`<type>/<short-desc>-<issueID>`。
- Worktree 路径保留分支路径：`.worktrees/<branch-name>`，例如 `.worktrees/feat/search-123`。
- 不复制当前未提交的变更。
- 不覆盖已有分支、worktree 或目录。

仅在给出 issue ID 时获取 issue 元数据：

```bash
gh issue view <issueID> --json title,body,number
```

验证：

```bash
git check-ref-format --branch <branch-name>
```

## 2. 高效检查

用一次工具调用获取本地状态：

```bash
git status --short
git branch --show-current
git worktree list --porcelain
git branch --list <branch-name>
test -e .worktrees/<branch-name>
```

仅在影响结果时才添加远程/新鲜度检查：

```bash
git branch --remotes --list '*/<branch-name>'
git fetch origin <base>
git rev-list --left-right --count <base>...origin/<base>
```

基准策略：

- 默认 `<base>` 为 `main`，除非仓库指引或用户指定了其他基准。
- 同仓库工作优先 `origin/<base>`，然后本地 `<base>`。
- 仅在 fork 工作流或明确指引时使用 `upstream/<base>`。
- 如果本地 `<base>` 已过时但选择了 `origin/<base>`，继续并报告本地 `<base>` 未更新。

仅在分支/worktree/路径已存在、基准选择不安全或对当前工作已过时，或脏的当前变更使意图模糊时才停止。否则报告脏的当前变更（如果有）已被排除。

## 3. 创建并验证

当分支名包含 `/` 时先创建父目录，然后添加 worktree：

```bash
mkdir -p .worktrees/<type>
git worktree add --no-track -b <branch-name> .worktrees/<branch-name> <base-ref>
```

对于同仓库工作，`<base-ref>` 通常是 `origin/main`（当可用时）。保持 `--no-track`；`git-push` 在分支发布时设置上游。

用一次调用验证：

```bash
git worktree list --porcelain
git -C .worktrees/<branch-name> branch --show-current
git -C .worktrees/<branch-name> status --short
pwd
```

在**新的 worktree 内部**运行 `pwd`。

报告分支、路径、基准引用、脏变更是否已排除、当前目录以及用户的 `cd .worktrees/<branch-name>` 命令。

## 4. 防护规则

- 除非明确要求，不执行 `git worktree remove`、`git worktree prune`、`rm`、`git reset`、`git stash`、`git push` 或 force 命令。
- 除非明确要求，不将受保护/共享基准分支创建为目标分支。
- 保持 `.worktrees/` 被 Git 忽略。
