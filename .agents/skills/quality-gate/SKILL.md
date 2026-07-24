---
name: quality-gate
description: 对当前分支改动执行分层验证；按 start-task 定档结果跑 L1 健康检查 / L2 单模块集成 / L3 跨模块 / L5 回归；任一层 FAIL 即停止，L5 发现硬编码密码则阻塞 PR。
---

# quality-gate

对当前分支的改动执行分层验证。

## 流程

**第一步：确认档位。** 读取 `docs/exec-plans/active/` 中对应任务的 exec-plan 文件，获取其 `- **档位**：` 字段值。若文件不存在或字段缺失，回退到询问用户或默认跑 Light 级别。

**第二步：按档位执行分层验证：**

**Light**: 只跑 L1
```bash
bash tests/scenarios/l1-smoke/health-check.sh
```

**Standard**: L1 → L2 → L3
```bash
bash tests/scenarios/l1-smoke/health-check.sh
bash tests/scenarios/l2-integration/run-l2-integration.sh
bash tests/scenarios/l3-e2e/run-l3-trade-flow.sh  # 无 Docker 自动跳过
```

**Full**: L1 → L2 → L3 → L5
```bash
# L1-L3 同上，加：
bash tests/scenarios/l5-regression/run-l5-regression.sh
```

## 阻断规则（Harness 质量门）

- 任何一层 FAIL → **调用 `diagnose` 归因**，确认根因后修复，再从失败层重跑。
- 同一层连续 FAIL 3 次后**不再自动重跑，上报用户决策**（是否跳过该层、回退变更、或人工介入）。
- L5 发现硬编码密码 → **阻塞，禁止创建 PR**。修完重跑 L5 全量。
- 无 Docker 时 L3 自动跳过不算 FAIL，但 L5 会检测到并标 WARNING。

## 禁区

- 不可跳过 L1 健康检查。
- L5 发现硬编码密码时不能继续。

## 输出

- 每层 PASS/FAIL + 最终 verdict。
