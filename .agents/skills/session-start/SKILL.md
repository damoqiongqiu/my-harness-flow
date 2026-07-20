---
name: session-start
description: 新会话恢复上下文：依次读 AGENTS.md → checklist/context.yaml → exec-plans → 最新 work-journal → git status，快速定位当前进度与下一步，并输出与任务相关的已知风险提示。
---

# session-start

**目标项目路径规则**：读 `docs/exec-plans/`、`docs/work-journal/` 时从**目标项目**读取。如果当前工作目录在 harness framework，先通过 AGENTS.md 或 `.agents/.harness-flow-installed` 定位目标项目路径。

恢复上下文：知道项目是什么、当前做到哪、下一步该干什么。

## 1. 流程

1. 读 `AGENTS.md`（项目导航入口）。
2. 读 `docs/plan/checklist.md`、`docs/plan/context.yaml`、`docs/exec-plans/active/`。
3. 读最新的 `docs/work-journal/` 条目。
4. 读 `docs/bugs/` 与项目踩坑记录（如有），**输出与当前任务相关的风险提示**。
5. 跑 `git status` 确认工作区状态。

## 2. 输出

- 当前任务的下一步 + 工作区是否干净 + **已知风险提示（必须出现，无相关风险时写"无相关已知风险"）**。
