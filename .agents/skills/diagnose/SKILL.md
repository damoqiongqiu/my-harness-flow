---
name: diagnose
description: quality-gate 失败或异常后的分层归因：严格按 test→env→artifact→code 顺序排查，确认代码 Bug 时在 docs/bugs/ 下沉淀复现步骤与根因；多数失败并非代码问题。若失败源为 CI / GitHub Actions，委托 diagnose-ci-failures 提取日志。
---

# diagnose

**目标项目路径规则**：bug 记录写入**目标项目**的 `docs/bugs/`。测试日志从目标项目的 `tests/scenarios/` 读取。

分析 quality-gate 失败或异常的根因，按优先级分层归因。

## 1. 归因前判断

0. **CI 还是本机？** 如果失败来自 GitHub Actions / CI workflow / PR checks，先调用 `diagnose-ci-failures` 提取 CI 日志与失败上下文。`diagnose-ci-failures` 会在无 gh CLI 时自动降级并返回，此时继续本机归因流程。CI 环境问题（如 key 缺失、缓存过期）与本机测试不同，避免误判为代码 Bug。

## 2. 归因顺序（按此顺序排查，不跳）

1. **测试本身**：断言对不对？fixture 环境变量是否缺失？上次跑绿是什么时候？
2. **环境**：运行环境是否正常？依赖服务（容器/数据库/消息队列等）是否可达？（跑 `bash tests/scenarios/l1-smoke/health-check.sh`）
3. **生成物/契约漂移**：schema 是否过期？codegen 输出是否刷新？contract 测试是否通过？
4. **代码**：最后才判定为代码 Bug。确认前三层无问题后，走 `tests/scenarios/l2-integration` 按模块缩小范围。

## 3. 输出

- 归因结论（哪一层 + 具体信号）+ 最小修复建议。
- 确认代码 Bug 时才标记需要改代码，多数失败不是代码问题。
- **确认为代码 Bug 后**：在 `docs/bugs/` 下创建 `<bug简述>.md`，含复现步骤 + 根因 + 修复建议。格式参考 `docs/bugs/` 下已有文件（如无先例则包含：标题、复现步骤、根因、修复建议四段）。之后进入 `start-task` 开始修复流程。
