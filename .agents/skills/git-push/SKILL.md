---
name: git-push
description: 将已提交的分支工作推送到正确的远程分支，进行最简检查，不使用不安全的 force push。
---

# git-push

在存在 commit 且用户要求推送或发布分支后使用。

## 0. 环境自适应

**推送前先检测远程仓库**（`git push` 本身与平台无关，GitHub/GitLab/Gitee 等均适用）：

```bash
git remote -v
```

如果 `git remote -v` 输出为空（无远程仓库），则说明这是纯本地项目：
- 告知用户："无远程仓库配置，跳过推送。在本地 commit 仍然有效。"
- **成功退出**（不报错），流程继续。

## 1. 检查

用一次工具调用检查推送状态：

```bash
git status --short
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name @{u}
git log --oneline @{u}..HEAD
```

如果上游查找失败，准备 `git push -u origin <branch>`，仅在 commit 集合不明确时使用近期本地 commit。

## 2. 推送

- 拒绝受保护/共享基准分支（`main`、`master`、`develop`、release 分支），除非明确要求。
- 脏工作树变更不会被推送；报告它们，仅在推送已有 commit 的意图仍然明确时继续。
- 使用普通推送以确保 hooks 运行：

```bash
git push
git push -u origin <branch>
```

## 3. 推送被拒

如果推送被拒，先 fetch 并检查差异。在 rebase、merge 或使用 `git push --force-with-lease` 之前先询问。除非用户明确要求该确切行为，绝不使用普通 `git push --force`。

报告当前分支、上游/远程分支、推送的 commit hash、推送结果，以及未推送的脏变更。

## 4. 仓库规则

- **禁止 force push 共享 base 分支**：main / master / develop 等共享分支禁止 force push（包括 --force-with-lease）
