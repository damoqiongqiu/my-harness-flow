---
name: git-commit
description: 基于真实 diff 创建整洁、仓库感知的 commit，包含聚焦的检查、选择性暂存和最少工具调用。
---

# git-commit

原子性地提交当前仓库变更，消息准确，不包含无关文件。

## 1. 检查

用一次工具调用完成常规检查：

```bash
git status --short
git diff --stat
git diff
git diff --cached --stat
git diff --cached
```

如果暂存区输出为空，忽略它。仅在仓库消息规范未知时检查：优先使用已有上下文，然后是显而易见的文件如 `.gitmessage`、`CONTRIBUTING.md` 或 commit 配置。仅在风格仍不明确时使用近期历史。

## 2. Commit 边界

只在真正不同关注点时拆分：行为 vs 重构、依赖变更 vs 代码、无源的生成输出、纯格式变更、无关文档/测试。将与修复/功能直接相关的测试保持在一起。

只暂存目标路径：

```bash
git add <specific-files>
```

仅在文件级暂存会混合无关变更时使用 `git add -p`。

## 3. 批准

如果用户要求 commit 明确的当前变更，检查后直接进行。仅在包含的文件、边界、风险内容或 issue 语义模糊时才先询问。问题保持简短：包含的文件、排除的文件、建议的消息以及模糊点。

## 4. 消息

默认格式，除非仓库规范另有说明：

```text
type(scope): summary
```

类型：`feat`、`fix`、`refactor`、`perf`、`docs`、`test`、`build`、`ci`、`chore`。在明显时使用 scope。避免 `update`、`changes`、`misc` 和 `wip`。

Issue 链接：

- 优先检测用户明确给出的 issue ID，然后是分支模式如 `<type>/<desc>-123`、`issue-123`、`gh-123` 或 `#123`。
- 仅在明确的关闭意图或明显完整的窄范围 issue 时使用 `Fixes #123`。
- 对部分、准备、仅文档、仅清理或模糊工作使用 `Refs #123`。
- 不虚构 issue ID。

## 5. 提交

使用普通 Git 以确保 hooks 运行：

```bash
git commit -m "<subject>"
```

如果 hooks 失败，停止并报告。除非明确要求，不使用 `--no-verify`、push、改写历史或 force 任何东西。

报告最终 commit hash 以及 hooks/检查是否运行。

## 6. 仓库规则

- **Commit 格式**：必须遵循 Conventional Commits — `type(scope): summary`
- **类型**：feat / fix / docs / refactor / test / chore / style / cleanup
- **范围**：按项目模块划分（模块清单见项目 `AGENTS.md`）
- **禁止 git add .**：必须精确 stage 变更文件（`git add <specific-files>`）
- **禁止跳过 hooks**：不允许 --no-verify
- **禁止禁用签名**：不允许 --no-gpg-sign
