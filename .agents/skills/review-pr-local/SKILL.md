---
name: review-pr-local
description: 使用临时目录快照和与 CI 相同的 review.json 合约，从当前分支本地运行仓库 PR 审查工作流。
---

# review-pr-local

在本地实现工作完成后、推送或创建 PR 前使用此 SKILL。它准备与 GitHub 审查 workflow 相同的审查输入，然后将审查逻辑委托给 `review-pr`。

## 1. 工作流

1. 从仓库根目录准备本地审查输入。优先使用与当前分支关联的 GitHub PR 获取 `pr_description.txt`，当无法获取 GitHub PR 时退回本地构建 PR 元数据。`pr_diff.txt` 快照从本地工作树 diff 构建。该命令将快照写入临时目录并打印选定的审查 skill 为 `skill=<path>` 以及精确文件路径：
   ```bash
   python3 .github/scripts/prepare_local_review_inputs.py
   ```
2. 读取命令打印的 `skill` 路径。
3. 严格遵循选定的 skill。它将在存在时应用引用的本地伴随指引。
4. 仅使用打印的快照路径作为审查输入：
   - `pr_description_path`
   - `pr_diff_path`
   - `spec_context_path`（非空时）
5. 当审查 skill 需要源代码上下文时，从当前仓库根目录检查仓库文件。
6. 仅将审查输出写入打印的 `review_path`。
7. 验证审查输出：
   ```bash
   python3 .github/scripts/validate_review_json.py <pr_diff_path> <review_path>
   ```
8. 验证审查阶段未修改仓库文件：
   ```bash
   python3 .github/scripts/validate_local_review_result.py \
     --baseline-status <baseline_status_path>
   ```

## 2. 安全规则

- 输入准备完成后，不运行 `git add`、`git commit`、`git push`、`gh` 或 GitHub API 命令。
- 不发表评论或变更 GitHub 状态。
- 不修改源码、workflow、测试、spec 或 skill 文件。
- 如果审查发现问题，通过 `review.json` 报告；在此 SKILL 期间不修复代码。
