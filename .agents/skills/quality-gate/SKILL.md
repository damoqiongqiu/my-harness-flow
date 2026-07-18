---
name: quality-gate
description: 对当前分支改动执行分层验证；按 start-task 定档结果跑 L1 冒烟 / L2 单元测试 / L3 E2E / L5 回归；任一层 FAIL 即停止，L5 发现硬编码密码则阻塞 PR。
---

# quality-gate

对当前分支的改动执行分层验证。

## 0. 环境自适应

**每层验证前先检测对应测试脚本是否存在**。执行各层验证时，按以下规则处理缺失的测试脚本：

| 验证层 | 脚本路径 | 不存在时的行为 |
|--------|---------|--------------|
| L1 冒烟 | `tests/scenarios/l1-smoke/health-check.sh` | 🟡 告知用户「L1 脚本未实现」，**跳过该层但不计 FAIL** |
| L2 单元 | `tests/scenarios/l2-integration/run-l2-integration.sh` | 🟡 告知用户「L2 脚本未实现」，**跳过该层但不计 FAIL** |
| L3 E2E | `tests/scenarios/l3-e2e/run-l3-e2e.sh` | 🟡 告知用户「L3 脚本未实现或运行环境不可用」，**跳过** |
| L5 回归 | `tests/scenarios/l5-regression/run-l5-regression.sh` | 🟡 告知用户「L5 脚本未实现」，**跳过** |

> 测试脚本由目标项目自行实现，框架只提供空骨架。项目启动阶段各层脚本可能不存在，属于正常状态。

## 1. 流程

按 `start-task` 判定的档位执行：

**Light**: 只跑 L1
```bash
bash tests/scenarios/l1-smoke/health-check.sh
```

**Standard**: L1 → L2 → L3
```bash
bash tests/scenarios/l1-smoke/health-check.sh
bash tests/scenarios/l2-integration/run-l2-integration.sh
bash tests/scenarios/l3-e2e/run-l3-e2e.sh  # 无运行环境自动跳过
```

**Full**: L1 → L2 → L3 → L5
```bash
# L1-L3 同上，加：
bash tests/scenarios/l5-regression/run-l5-regression.sh
```

## 2. 阻断规则（Harness 质量门）

- 任何一层 FAIL → **调用 `diagnose` 归因**，确认根因后修复，再从失败层重跑。
- L5 发现硬编码密码 → **阻塞，禁止创建 PR**。修完重跑 L5 全量。
- 无运行环境（如容器/依赖服务不可用）时 L3 自动跳过不算 FAIL，但 L5 会检测到并标 WARNING。

## 3. 禁区

- 不可跳过 L1 健康检查。
- L5 发现硬编码密码时不能继续。

## 4. 输出

- 每层 PASS/FAIL + 最终 verdict。
