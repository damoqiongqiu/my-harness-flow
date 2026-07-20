---
name: retrospect
description: 基于 work-journal 与 quality-score 证据的复盘：将重复失败转成可执行规则改进，输出评估报告；无证据不复盘，复盘点必须可执行。
---

# retrospect

**目标项目路径规则**：复盘数据源（`docs/work-journal/`）和输出报告（`docs/reports/`）均操作**目标项目**，非 framework 项目。

基于证据的复盘，把重复失败转成规则改进。

## 1. 流程

1. 读最近 `docs/work-journal/` 条目。
2. 读 `docs/reports/quality-score.md` 当前度量。
3. 将发现的阻点或模式写为 `docs/reports/assessment-YYYY-MM-DD.md`。
4. 如有规则变化，更新对应的根文档。

## 2. 禁区

- 无证据不复盘（必须有 work-journal 记录）。
- 复盘点必须可执行（不写泛泛感想）。

## 3. 输出

- 评估报告路径。
