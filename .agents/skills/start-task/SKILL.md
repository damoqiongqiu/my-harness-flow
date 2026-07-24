---
name: start-task
description: 收到开发需求后的第一道门禁：按改动规模与风险定档（Light/Standard/Full），判断是否需要 spec 驱动（歧义/规模/跨模块/高风险 → 直接创建 spec 骨架并调用 write-product-spec / write-tech-spec 填充），否则直接创建特性分支并写 exec-plan 进度文件。前置条件：先执行 session-start 完成上下文恢复。
---

# start-task

**前置条件**：必须先执行 `session-start` 完成上下文恢复（读 context.yaml / exec-plans / work-journal / git status），再做本步。

## 流程

### 1. 定档

判断改动范围，按 `AGENTS.md` 定档表匹配档位（行数 + 文件数双标准）：

- Light: < 50 行、≤ 2 文件、纯 bug/样式/配置 → quality-gate 只跑 L1
- Standard: 50-200 行、2-5 文件、新接口、单模块 → quality-gate 跑 L1-L3
- Full: > 200 行、> 5 文件、跨模块、碰安全/支付/数据库/上线 → quality-gate 跑 L1-L5
- 核心模块（match-engine/trade/gateway）自动升一档
- **拿不准时先报告评估结果，等用户确认档位再继续**；碰安全面直接 Full（不等待）

### 2. 读取 specs 目录规范

在执行 spec 判断之前，**先检查 `specs/README.md` 是否存在**。若存在，读取它了解本项目 spec 目录结构、命名规则、各档位 spec 要求以及生命周期规范。

> ⚠️ `specs/README.md` 中的约定**优先于**本 skill 的通用规则。例如 README 要求 Light 档也至少写 product.md，则按 README 执行，不因本 skill 说"Light 不需要"而跳过。

### 3. 判断是否需要走完整的 spec 驱动流程

> **注意**：即使不走完整 spec 驱动流程，也可能需要按 README 要求创建轻量级 spec。下面的判断只决定是否走"写 product + tech spec → 审查 → 实现"的完整链路。

以下情况**向用户建议走完整 spec 驱动路线**，说明理由（命中哪几条），等用户确认后执行后续步骤：

- 需求存在产品、workflow 或架构歧义
- 预期实现规模约 1k+ 行或 >5 文件
- 深层或跨切面的堆栈变更（跨模块、跨服务）
- 回归后果严重的高风险行为变更
- agent 驱动实现需要比 issue 更清晰的输入

**不需要走完整 spec 驱动的典型场景**：小型本地 bug 修复、简单重构、窄范围 UI 调整、低风险单文件变更。**拿不准时列出判断依据，让用户决定。**

> 若 `specs/README.md` 要求 Light 级至少 `product.md`，则在判定不走完整 spec 驱动后、创建分支前，**先按以下步骤处理**：
> 1. 衍生一个简短的 slug（同 §3.1 规则）
> 2. 创建 `mkdir -p specs/<slug>/`
> 3. 复制模板：先用 `specs/_template-product.md`，不存在则用 `templates/specs/_template-product.md`
> 4. **调用 `write-product-spec` SKILL** 填充内容（携带用户已提供的需求上下文）
> 5. 然后继续 §4 创建分支
>
> 否则不需要处理 spec，直接进入 §4 创建分支。

#### 3.1 用户确认走完整 spec 驱动后

> 🔒 **自动模式激活**：从此刻起，Agent 进入全自动执行模式，**不再向用户提问**。遇到任何歧义或信息缺失时，做合理假设并记录到 spec 的"待解决问题"章节中（`product.md` §9 或 `tech.md` §8）。实现过程中的设计选择同理——做合理决策，不停下来问。

1. **衍生 slug**：从任务描述中提取一个简短的功能简称，全小写字母+连字符（如 `add-2fa`、`fix-order-precision`）。优先按 `specs/README.md` 的命名规则（有 issue → `issue-<N>/`）。**记住此 slug，后续步骤（§5 写 exec-plan、§8 代码实现）会用到它来关联 specs 目录**
2. **创建 specs 子目录**：`mkdir -p specs/<slug>/`
3. **从模板实例化两份 spec 骨架文件**（模板由 `my-harness-cli.sh` 安装时同步到 `specs/` 目录）：
   - 复制 `specs/_template-product.md` → `specs/<slug>/product.md`
   - 复制 `specs/_template-tech.md` → `specs/<slug>/tech.md`
4. **填充 spec 内容**：
   - **首先调用 `write-product-spec` SKILL**，填充 `specs/<slug>/product.md`。该 skill 会读取现有骨架，按产品 spec 规范完成内容书写。**调用时携带用户已提供的需求描述/文档作为输入上下文**
   - **判断是否需要技术 spec**：Standard 或 Full 档任务、架构有显著变化、跨模块/跨服务变更时，**再调用 `write-tech-spec` SKILL** 填充 `specs/<slug>/tech.md`。同样携带用户提供的技术约束和上下文；纯 UI 变更或简单逻辑可省略
5. **通知用户**：已完成 spec 骨架创建和内容填充（`specs/<slug>/product.md` + 可选 `tech.md`）。参考 `spec-driven-implementation` SKILL 了解完整的生命周期管理（保持更新、审查、验证等），但不额外跳转

> ⚠️ `_template-product.md` 和 `_template-tech.md` 由 `my-harness-cli.sh` 安装时同步到目标项目的 `specs/` 目录。若目标项目 `specs/` 下没有模板文件，再检查 `templates/specs/`（框架本体仓库），两处都没有则报错提示用户运行安装器补全。

### 4. 创建分支

用 `git-branch` 创建特性分支，格式 `<type>/<short-desc>`（前缀见 `AGENTS.md`）。

### 5. 写进度文件

在 `docs/exec-plans/active/<任务简称>.md` 创建进度文件。按是否创建了 spec 分三种格式：

**有 spec 文件（完整 spec 驱动 §3.1 或 Light 级补写）—— 精简格式，引用 spec：**

```markdown
# <任务简称>

- **档位**：{§1 判定结果}
- **分支**：{§4 分支名}
- **阶段**：实现中
- **Spec 目录**：`specs/<slug>/`（含 product.md，可能还有 tech.md）
```

> spec 中的验收标准、实现计划、验证方式即为该任务的完整执行计划，exec-plan 不再重复书写。

**未创建 spec 文件 —— 完整格式（含目标和验证方式）：**

```markdown
# <任务简称>

- **档位**：{§1 判定结果}
- **分支**：{§4 分支名}
- **阶段**：实现中

## 目标

{从需求描述提炼的目标要点}

## 验证方式

{按档位对应的 quality-gate 层级或其他验证手段}
```

### 6. （可选）建 Issue

如有 `gh` CLI 且仓库有 GitHub remote，用 `create-issue` 建 issue 跟踪。

### 7. （可选）写 plan 方案摘要

Standard / Full 档任务或用户明确要求时，写入 `docs/plan/<任务简称>.md`（标题 + 档位 + 目标 + 范围 + 验证方式）。

### 8. 实现 → 验证 → 收尾

#### 8.1 实现阶段

完成以上步骤后进入代码实现。**开始前先确认 git 工作区：**

- 检查当前分支是否为 §4 创建的特性分支（`git branch --show-current`）
- 若不是或工作区不干净，先修复状态再继续

**写代码前，必须先读取本次任务相关的 spec 文件：**

- **走完整 spec 驱动路径（§3.1）**：读取 `specs/<slug>/product.md` 和 `specs/<slug>/tech.md`——product.md 定义"要做什么"，tech.md 定义"怎么做"。实现必须以满足 spec 中的验收标准和实现计划为准绳
- **按 README 补了 Light 级 spec**：读取对应的 product.md，以它作为行为指引
- **未涉及 spec**：以用户原始需求描述为指引

实现过程中如发现预期行为与 spec 偏离，**必须回头更新 spec** 使其与实际交付一致（参考 `spec-driven-implementation` 的保持更新指引）。代码变更和 spec 更新应在同一 PR 内完成。

#### 8.2 验证阶段（实现完成后）

代码实现完成后，**立即调用 `quality-gate` SKILL** 执行分层验证：

- 按 `start-task` §1 判定的档位跑对应层级（Light → L1，Standard → L1-L3，Full → L1-L5）
- quality-gate 全部 PASS → 进入 8.3 收尾
- 任一层 FAIL → **调用 `diagnose` SKILL 归因**（按 test→env→artifact→code 顺序排查），确认并修复根因后从失败层重跑 quality-gate。同一层连续 FAIL 3 次则**上报用户决策**，不再自动重跑

#### 8.3 收尾阶段（quality-gate 通过后）

quality-gate 全部通过后，**调用 `finish-task` SKILL** 完成：

- 精确 stage 变更文件 → commit → push → 创建 PR
- 将 exec-plan 从 active/ 移至 completed/
- 写 work-journal 交付记录

> 三个子阶段（实现→验证→收尾）的顺序不可颠倒。quality-gate 未通过不得进入收尾。

## 禁区

- 不碰 `main` 直接改。
- 不同时在一个分支上做多个不相关的改动。

## 输出

- 若按 §3.1 或 README 要求创建了 spec 文件：报告 spec 路径（`specs/<slug>/product.md`、`specs/<slug>/tech.md`）和填充状态，并说明下一步进入代码实现阶段
- 否则：档位（Light/Standard/Full）+ 分支名
