---
name: start-task
description: 收到开发需求后的第一道门禁：按改动规模与风险定档（Light/Standard/Full），判断是否需要 spec 驱动（歧义/规模/跨模块/高风险 → 重定向到 spec-driven-implementation），否则直接创建特性分支并写 exec-plan 进度文件。前置条件：先执行 session-start 完成上下文恢复。
---

# start-task

**前置条件**：必须先执行 `session-start` 完成上下文恢复（读 context.yaml / exec-plans / work-journal / git status），再做本步。

**目标项目路径规则**：exec-plan 必须写入**目标项目**的 `docs/exec-plans/active/`。如果当前工作目录在 harness framework 项目，先通过 AGENTS.md 或对话上下文确定目标项目的绝对路径，再操作。禁止将目标项目的 exec-plan 写入 framework 项目。

## 1. 流程

### 1.1 定档

按四维判断（**任一维度命中更高档位，整体升档**）：

| 维度 | Light | Standard | Full |
|------|-------|---------|------|
| 风险域 | 无（文档/注释/格式） | 一般逻辑 | **安全/支付/数据完整性/权限/核心** |
| 影响面 | 单文件 | 2-5 文件 | >5 文件或跨模块 |
| 行为变更 | 无（重构/格式/补测试） | 新增行为 | 破坏性变更/API 不兼容 |
| 规模 | <50 行 | 50-200 行 | >200 行（辅助判定） |

定档优先级：**风险域 > 影响面 > 行为变更 > 规模**。

特殊规则：
- **仅文档**：纯 `docs/`、注释、README 变更 → **Light**，忽略其他维度
- **仅测试**：纯 `tests/`、`*.test.*`、`*.spec.*` 变更 → **Light**，忽略其他维度
- **安全相关**：auth/payment/data/permission/加密 → **自动 Full**，不允许降档
- 核心模块（match-engine/trade/gateway 等项目约定）→ 自动升一档
- **拿不准时先报告评估结果，等用户确认档位再继续**

### 1.2 判断是否需要 spec 驱动

以下情况**向用户建议走 `spec-driven-implementation`**，说明理由（排中哪几条），等用户确认后重定向：

- 需求存在产品、workflow 或架构歧义
- 预期实现规模约 1k+ 行或 >5 文件
- 深层或跨切面的堆栈变更（跨模块、跨服务）
- 回归后果严重的高风险行为变更
- agent 驱动实现需要比 issue 更清晰的输入

不需要 spec：小型本地 bug 修复、简单重构、窄范围 UI 调整、低风险单文件变更。**拿不准时列出判断依据，让用户决定。**

### 1.3 创建分支

用 `git-branch` 创建特性分支，格式 `<type>/<short-desc>`（前缀见 `AGENTS.md`）。

### 1.4 写进度文件

在 `docs/exec-plans/active/<任务简称>.md` 创建进度文件（标题 + 档位 + 分支名 + 阶段 = 实现中）。

### 1.5 （可选）建 Issue

如有 `gh` CLI 且仓库有 GitHub remote，用 `create-issue` 建 issue 跟踪。

### 1.6 （可选）写 plan 方案摘要

Standard / Full 档任务或用户明确要求时，写入 `docs/plan/<任务简称>.md`（标题 + 档位 + 目标 + 范围 + 验证方式）。

## 2. 禁区

- 不碰 `main` 直接改。
- 不同时在一个分支上做多个不相关的改动。

## 3. 输出

- 若走 spec 驱动路径：说明已重定向到 `spec-driven-implementation`，不继续后续
- 否则：档位（Light/Standard/Full）+ 分支名
