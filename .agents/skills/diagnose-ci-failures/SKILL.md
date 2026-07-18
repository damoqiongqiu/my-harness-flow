---
name: diagnose-ci-failures
description: 使用平台 CLI 诊断 PR/MR、分支、运行 ID 或 CI/CD 运行 URL 的 CI 失败（GitHub Actions: gh / GitLab CI: glab），提取错误日志，并生成修复计划。
---

# 诊断 CI 失败

以可编程方式诊断 CI 失败并生成修复计划。

## 0. 环境自适应

### 平台检测

根据 `git remote -v` 输出判定 CI/CD 平台：

```bash
git remote -v
# 检测可用 CLI
command -v gh >/dev/null 2>&1 && echo "gh: available" || echo "gh: missing"
command -v glab >/dev/null 2>&1 && echo "glab: available" || echo "glab: missing"
```

| 远程 URL 特征 | 平台 | CLI | CI 查看命令 | 概念 |
|-------------|------|-----|-----------|------|
| 含 `github.com` | GitHub Actions | `gh` | `gh run view <run-id> --verbose` | Workflow / Run / Job |
| 含 `gitlab` | GitLab CI | `glab` | `glab ci view` / `glab pipeline ci view <id>` | Pipeline / Job |

### 降级条件

`gh` 和 `glab` 都不可用时：
- 告知用户："无可用的 GitHub CLI (gh) 或 GitLab CLI (glab)，无法访问 CI/CD 运行日志。请在 CI 环境内或已安装对应 CLI 的本地环境中使用此技能。"
- **成功退出**（不报错）。诊断流程退回给上层 `diagnose` 技能继续本地归因。

## 1. 概览

此 SKILL 提供了一个确定性的工作流来检查 CI 状态、提取失败日志、分析错误并创建解决问题的计划。输出始终是一份可在执行前审查的计划文档。

此 SKILL 仅用于诊断。不要进行代码更改、commit、push 或 PR。

## 2. 工作流

### 2.1 定位失败的 CI 目标

从用户输入确定 CI 目标。

如果用户提供了 GitHub Actions 运行 URL，从 URL 中提取运行 ID：

```bash
gh run view <run-id> --verbose
```

示例 URL：

```text
https://github.com/OWNER/REPO/actions/runs/RUN_ID
```

如果用户直接提供了运行 ID：

```bash
gh run view <run-id> --verbose
```

如果用户提供了分支名：

```bash
gh run list --branch <branch> --status failure --limit 5
gh run view <run-id> --verbose
```

如果没有提供分支、运行 ID 或 URL，使用当前 checkout。首先检查当前分支是否有关联的 PR：

```bash
gh pr view --json number,title,url,state,statusCheckRollup
```

对于当前 PR 分支，列出失败的 PR 检查：

```bash
gh pr view --json statusCheckRollup --jq '.statusCheckRollup[] | select(.conclusion == "FAILURE")'
```

如果当前分支没有关联 PR，退回到当前分支最近失败的 workflow 运行：

```bash
git branch --show-current
gh run list --branch <branch> --status failure --limit 5
gh run view <run-id> --verbose
```

如果没有找到失败的 PR 检查或失败的 workflow 运行，报告未找到失败 CI 目标并停止。

### 2.2 检查 CI 状态

获取所选 PR、分支或运行的所有 CI 检查状态。

对于 PR 分支：

```bash
gh pr view --json statusCheckRollup
```

对于 workflow 运行：

```bash
gh run view <run-id> --verbose
```

解析输出以识别：

- 已完成的检查
- 进行中的检查
- 成功的检查
- 失败的检查，包括名称、运行 ID、作业 ID 和详情 URL（如果可用）

如果 CI 仍在运行，告知用户哪些检查已经失败或通过，高亮仍在运行的检查，建议等待完成后再进行最终诊断。

### 2.3 提取失败日志

对于每个失败的运行或检查，拉取失败步骤的日志：

```bash
gh run view <run-id> --log-failed
```

需要更深入检查时：

```bash
gh run view <run-id> --log --job <job-id>
gh run download <run-id> -D .artifacts/<run-id>
```

重点提取：

- 错误消息和位置，包括文件路径和行号
- 构建或编译错误
- Lint 或格式化失败
- 测试失败消息、失败测试名称、堆栈跟踪和断言输出
- 环境或 CI 设置失败，如缺失密钥、权限不足、服务不可用、依赖安装失败或资源限制

### 2.4 分类错误

按类型分组错误：

- **构建/编译错误**：类型错误、语法错误、缺失导入、缺失依赖、版本不兼容、构建失败
- **测试失败**：失败的测试、断言失败、快照不匹配、超时、集成失败、看起来 flaky 的行为
- **Lint/格式化问题**：格式化工具失败、linter 违规、未使用代码、风格违规
- **环境问题**：缺失密钥、权限不足、服务不可用、CI 镜像问题、依赖下载失败、资源限制、平台特定设置问题

当工具有语言特异性时，仅作为从日志中观察到的事实提及，不作为假设。

### 2.5 生成修复计划

创建计划文档，包含：

- **问题陈述**：失败的检查或 workflow 运行摘要
- **当前状态**：发现了哪些错误、错误发生位置以及哪些检查受影响
- **根因分析**：基于日志，每个失败类别最可能的原因
- **建议的变更**：每个错误类别需要的具体修复
- **验证步骤**：为验证修复而应运行的命令或 CI 检查

不要实现修复。计划应足够具体以便后续实施任务执行。

## 3. 重要说明

- 始终先创建计划。绝不直接进行代码更改。
- 优先使用 CI 日志中的证据，而非本地假设。
- 如果测试在本地失败但在 CI 中通过，将其视为本地/环境特定问题，除非 CI 日志显示相同失败。
- 如果 CI 日志显示多个不相关的失败，将其分组并建议一次修复一个类别。
- 在从仓库文件或 CI 日志中观察到之前，避免假设编程语言、包管理器、测试框架或构建系统。

## 4. 常见 CI 检查类型

- 格式化和 lint
- 单元测试
- 集成测试
- 构建或打包检查
- 平台特定测试
- 部署或产物检查
- CI 摘要或必需状态检查

## 5. 示例命令

获取当前 PR 分支的失败检查：

```bash
gh pr view --json statusCheckRollup --jq '.statusCheckRollup[] | select(.conclusion == "FAILURE")'
```

获取某分支最近的失败运行：

```bash
gh run list --branch <branch> --status failure --limit 5
```

检查特定运行：

```bash
gh run view <run-id> --verbose
```

获取特定运行的失败日志：

```bash
gh run view <run-id> --log-failed
```

检查特定失败的作业：

```bash
gh run view <run-id> --log --job <job-id>
```
