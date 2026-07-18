---
name: bootstrap-issue-config
description: 通过分析仓库现有的 issue、标签和贡献者，生成 issue 分类配置文件（GitHub: `.github/issue-triage/` / GitLab: `.gitlab/issue-triage/`）和 `CODEOWNERS`，引导启动 issue 分类自动化配置。
---

# 引导 issue 分类配置

分析目标仓库并生成（或更新）供 `triage-new-issues` workflow 使用的 issue 分类配置文件。

## 0. 环境自适应

### 平台检测

执行前先检测可用 CLI 工具和平台：

```bash
# 检测平台
git remote -v
# 检测可用 CLI
command -v gh >/dev/null 2>&1 && echo "gh: available" || echo "gh: missing"
command -v glab >/dev/null 2>&1 && echo "glab: available" || echo "glab: missing"
```

根据平台选择 CLI 和输出路径：

| 平台 | CLI | 输出路径 | label 查看命令 |
|------|-----|---------|-------------|
| GitHub | `gh` | `.github/issue-triage/config.json` | `gh label list --repo <repo> --limit 200 --json name,color,description` |
| GitLab | `glab` | `.gitlab/issue-triage/config.json` | `glab label list --repo <repo>` |

### 降级条件

`gh` 和 `glab` 都不可用时：
- 告知用户："无可用的 GitHub CLI (gh) 或 GitLab CLI (glab)，无法自动发现标签和贡献者。你可以手动编写配置文件。"
- **成功退出**（不报错）。

> GitLab 同样支持 `CODEOWNERS` 文件（放在仓库根目录），配置格式与 GitHub 兼容。

## 1. 输出产物

此 SKILL 会生成两个文件：

1. **`.github/issue-triage/config.json`** — 分类过程中使用的标签定义。
2. **`.github/CODEOWNERS`** — CODEOWNERS 风格的从路径模式到 GitHub 用户名的所属关系映射。

## 2. 工作流

### 2.1 发现现有标签

- 使用 `gh label list --repo <owner>/<repo> --limit 200 --json name,color,description` 获取仓库当前定义的所有标签。
- 将每个标签归类为三种类别之一：
  - **area** 标签 — 标识组件或子系统（如 `area:api`、`area:docs`）。
  - **feature** 标签 — 标识能力或请求类型（如 `enhancement`、`bug`、`documentation`）。
  - **status** 标签 — 标识 workflow 状态（如 `triaged`、`needs-info`、`wontfix`）。
- 如果仓库标签很少或没有，用合理的默认值初始化配置：
  - `triaged`（状态）、`bug`（功能）、`enhancement`（功能）、`documentation`（功能）、`needs-info`（状态）、`duplicate`（状态）
  - `repro:high`、`repro:medium`、`repro:low`、`repro:unknown`（状态）

### 2.2 分析最近的 issue

- 使用 `gh issue list --repo <owner>/<repo> --state all --limit 100 --json number,title,labels,createdAt` 获取最近的 issue。
- 如果 issue 使用了尚未捕获的标签，将其添加到相应类别。
- 检查 `.github/ISSUE_TEMPLATE/` 中的模板文件 — 模板名称和模板中引用的标签可以为标签发现提供信息。

### 2.3 生成或更新 `config.json`

- 读取已有的 `.github/issue-triage/config.json`。
- 将新发现的标签合并到已有的 `labels` 对象中。**不要**删除配置中已存在的标签 — 只添加或更新。
- 配置必须**仅**包含 `labels` 键。**不要**包含 `stakeholders` 或 `default_experts`。
- `labels` 必须是一个扁平对象，key 为精确的 GitHub 标签名（含前缀，如 `area:workflow` 或 `repro:high`）。不要按类别嵌套标签。
- 每个标签条目必须包含 `color`（6 位十六进制，不含 `#`）和 `description`（一句话描述）：
  ```json
  {
    "labels": {
      "triaged": {
        "color": "0E8A16",
        "description": "此 issue 已完成初始分类"
      },
      "area:workflow": {
        "color": "7057FF",
        "description": "GitHub workflow、Python 自动化或集成"
      }
    }
  }
  ```
- 将结果写入 `.github/issue-triage/config.json`。
- 使用 `jq . .github/issue-triage/config.json` 验证。

### 2.4 生成或更新 `.github/CODEOWNERS`

- 如果 `CODEOWNERS` 存在，检查它以获取初始归属提示。
- 使用 `git log --format='%aN <%aE>' --since='6 months ago' -- <path>` 和 `gh api` 识别主要目录的近期贡献者。
- 读取已有的 `.github/CODEOWNERS` 文件，合并新条目而非覆盖。
- 按 CODEOWNERS 规范编写文件：
  ```
  # 语法遵循 CODEOWNERS 规范：后续规则优先。
  # 当 branch protection 要求时，GitHub 可能会请求代码所有者审查。

  # --- 区域注释 ---
  /path/pattern/ @owner1 @owner2
  ```
- 每行将一个路径 glob 映射到一个或多个 `@username` 所有者。

### 2.5 创建缺失的标签

- 对于最终 `config.json` 中仓库上尚不存在的每个标签，创建它：
  ```
  gh label create "<name>" --color "<color>" --description "<description>" --repo <owner>/<repo>
  ```
- 跳过已存在的标签（`gh label create` 命令在重复标签上会报错 — 忽略这些错误）。

### 2.6 记录仓库本地伴随 SKILL（不要搭建）

支持仓库特定伴随的可复用 agent 角色有：

- `.github/skills/review-pr-repo/SKILL.md`
- `.github/skills/review-spec-repo/SKILL.md`
- `.github/skills/triage-issue-repo/SKILL.md`
- `.github/skills/dedupe-issue-repo/SKILL.md`

在 bootstrap 期间**不要**创建这些文件。prompt 构建层会将缺失的伴随文件与仅含 body 的 frontmatter 存根等同对待，因此在 bootstrap 期间物化空文件没有价值。每个文件由匹配的 `update-<agent>` 自我改进循环（或由维护者）在首次有证据支持的内容需要添加时按需创建。Bootstrap 只需要确保目录约定已被记录；文件本身保持缺失直到真正的规则落地。

如果仓库中已存在伴随文件，保持不动；bootstrap 是增量操作。

### 2.7 验证和总结

- 使用 `jq` 重新验证 `config.json`。
- 打印简短总结：
  - 发现了多少标签 vs 新创建了多少标签。
  - 写入了多少条 codeowner 条目。
  - 仓库中已存在哪些仓库本地伴随 SKILL（如果有）。
  - 任何警告（如未找到 issue、无 CODEOWNERS 文件）。

## 3. 幂等性

此 SKILL 设计为可安全地多次运行。重新运行将：
- 将新标签合并到已有配置，不删除旧标签。
- 合并新的 codeowner 条目，不重复已有行。
- 跳过仓库上已存在的标签创建。

## 4. 假设

- `gh` CLI 已认证并有权访问目标仓库。
- 从仓库根目录运行此 SKILL。
- 除非 prompt 另有指定，目标仓库为当前工作目录。
