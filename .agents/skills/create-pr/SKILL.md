---
name: create-pr
description: 从已推送的分支创建或更新 PR/MR（GitHub / GitLab），经过本地审查、基准分支同步、验证和 issue 关联。
---

# create-pr

在 `git-push` 之后，当用户要求创建、更新或开启 PR/MR（GitHub Pull Request / GitLab Merge Request）时使用。

## 0. 环境自适应

### 平台检测

**先检测远程仓库平台**，确定使用哪个 CLI 工具和术语：

```bash
# 检测远程仓库 URL
git remote -v
```

根据 `git remote -v` 输出判定平台：

| 远程 URL 特征 | 平台 | CLI 工具 | 术语 |
|-------------|------|---------|------|
| 含 `github.com` | GitHub | `gh` | PR (Pull Request) |
| 含 `gitlab` | GitLab | `glab` | MR (Merge Request) |
| 其他或无远程 | 本地 | 无 | — |

之后所有操作根据判定结果选择对应 CLI：
- GitHub: `gh pr create --base <base> --head <branch> --title "..." --body "..."`
- GitLab: `glab mr create --source-branch <branch> --target-branch <base> --title "..." --description "..."`

### 降级条件

`gh` 和 `glab` 都不可用时：
- 告知用户："无可用的 GitHub CLI (gh) 或 GitLab CLI (glab)，跳过 PR/MR 创建。本地 commit 和归档仍然有效。"
- **成功退出**（不报错），流程继续。

## 1. 目标

从当前分支创建或更新一个可供审查的 PR：同步基准分支、本地审查 diff、关联相关任务。

## 2. 工作流

1. **检查并选择基准分支**
   运行：
   ```bash
   git status --short
   git branch --show-current
   git status -sb
   ```
   优先使用仓库的默认 PR 基准。如果仓库指引指定了不同的基准，使用那个。
   如果工作树脏了，暂停，除非这些变更是有意不纳入 PR 的。

2. **本地审查并同步**
   运行：
   ```bash
   git diff --stat <base>...HEAD
   git diff <base>...HEAD
   ```
   审查 diff 中是否有误包含的文件、密钥、冲突标记、生成代码的变动，以及缺失的测试或文档。
   在创建或更新 PR 前，先获取基准分支并确保其已合并或 rebase 到当前分支。
   如果发生冲突，本地解决，重新运行相关验证，提交解决方案，并通过 `git-push` 推送，以确保已配置的 `pre-push` hook 运行。

3. **构建标题、正文和 issue 链接**
   标题默认为 issue 标题或主 commit 的 subject。
   从用户请求、分支名或 commit 中推断 issue 链接。不要虚构 issue ID。
   正文保持简洁，包含：
   - 摘要
   - 已执行的验证
   - issue 链接，如已知则使用 `Closes #123`、`Fixes #123` 或 `Refs #123`

4. **创建或更新 PR**
   在 GitHub CLI 可用时使用它。首先仅检查当前分支是否有**打开的** PR。不要使用 `gh pr view` 作为存在性检查，因为它可能解析到同分支名之前已合并或已关闭的 PR：
   ```bash
   pr_url="$(gh pr list --state open --head "$branch" --json url --jq '.[0].url' --limit 1)"
   ```
   如果 `pr_url` 非空，更新该打开的 PR 而非创建重复项：
   ```bash
   gh pr edit "$pr_url" --title "$title" --body-file "$body_file"
   ```
   在编辑已打开的已有 PR 前，先读取当前正文，保留非由此 workflow 生成的手动内容。不要为了套用生成的摘要而覆盖手动备注、审查上下文、checklist 条目或发布信息。
   如果没有打开的 PR，创建一个。同分支名已合并或已关闭的 PR 不可复用，不得阻止创建新 PR：
   ```bash
   gh pr create --base "$base" --head "$branch" --title "$title" --body-file "$body_file"

   # GitLab
   glab mr create --source-branch "$branch" --target-branch "$base" --title "$title" --description "$(cat "$body_file")"
   ```
   将生成的标题/正文/基准/头部分支值作为独立 argv 风格参数传入。
   不要将从用户、issue、分支或 commit 中提取的文本直接粘贴到 shell 命令行中；如果使用 shell 变量，不带 `eval` 或命令替换地填充它们，并始终给扩展加引号。

如果 `gh` 不可用或未认证，报告手动创建或更新 PR 所需的精确标题/正文/基准/头部分支。

## 3. 报告

创建或找到 PR 后，报告：

- PR URL
- 基准分支
- 头部分支
- 标题
- 正文中包含的验证信息
- 基准分支是否已在本地合并或 rebase
- 提醒用户关注 CI、回复审查评论、通过定期合并或 rebase 基准分支保持 PR 最新

## 4. 仓库规则

- **PR 描述须包含**：summary / validation evidence（测试结果/截图/日志）/ issue link
- **安全铁律**：禁止提交含明文密码或 token 的代码（详见项目安全规范文档）
- **基础设施改动**：如果是 infra 相关改动，PR 描述中引用项目基础设施文档的验证命令
