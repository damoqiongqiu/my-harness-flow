---
name: git-branch
description: 创建符合仓库规范的分支，包含高效的 issue 命名、基准选择和安全性检查。
---

# git-branch

用最少的必要检查创建开发分支，避免错误的名称、错误的基准或覆盖。

## 1. 命名

- 关联 issue：`<type>/<short-desc>-<issueID>`。
- 无 issue：`<type>/<user-provided-name>`；绝不虚构 issue ID。
- 类型：`feat`、`fix`、`refactor`、`docs`、`test`、`perf`、`chore`。
- 保留用户给出的有效类型；否则从任务推断，默认为 `chore`。
- 规范化为 `-` 分隔的简短小写英文单词；删除标点、填充词、重复分隔符和非分支字符。

如果用户给出了 issue 引用，运行一次 `gh` 调用：

```bash
gh issue view <issueID> --json title,body,number
```

用标题作为 `short-desc`；仅在需要时退回正文或用户上下文。如果未提及 issue，不调用 `gh`。如果 `gh` 失败但上下文足够，继续并报告 issue 元数据未验证。

验证：

```bash
git check-ref-format --branch <branch-name>
```

## 2. 高效检查

本地检查优先用一次 shell 调用：

```bash
git status --short
git branch --show-current
git branch --list <branch-name>
```

仅在影响结果时才添加远程/新鲜度检查：

```bash
git branch --remotes --list '*/<branch-name>'
git fetch origin <base>
git rev-list --left-right --count <base>...origin/<base>
```

基准策略：

- 默认 `<base>` 为 `main`，除非仓库指引或用户指定了其他基准。
- 同仓库工作优先 `origin/<base>` 而非 `upstream/<base>`。
- 仅在 fork 工作流或明确指引时使用 `upstream`。
- 不要让新分支跟踪基准；`git-push` 稍后设置上游。

仅在以下情况停止：目标分支已存在、脏工作树意图模糊、当前/基准分支明显不安全，或新鲜度检查显示所选基准过时。

## 3. 创建

使用以下之一：

```bash
git switch -c <branch-name> <base>
git switch --no-track -c <branch-name> origin/<base>
```

然后验证：

```bash
git branch --show-current
```

## 4. 防护规则

- 除非明确要求，不执行覆盖、reset、stash、delete 或 force 操作。
- 没有用户意图时不切换到已有分支。
- 除非明确要求，不创建受保护/共享基准分支（`main`、`master`、`develop`、release 分支）。
- 仅在可能有影响时才报告跳过的 freshness 检查。

## 5. 分支命名规范

- **类型前缀**：feat/ fix/ docs/ refactor/ test/ chore/
- **命名格式**：`<type>/<short-desc>`（如 `feat/user-auth-oauth`、`fix/order-timeout`）
- **基准分支**：须从 clean main 创建分支
