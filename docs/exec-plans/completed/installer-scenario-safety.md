# installer-scenario-safety

- **档位**：Standard 升 Full（installer 核心模块，约 150 行改动单文件）
- **分支**：`feat/installer-scenario-safety`
- **阶段**：已完成（2026-07-17 12:25）

## 1. 需求（用户提出的三场景）
1. 全新空工程：静默完整安装，零提问
2. 老项目已有 AGENTS.md 等文档 / 定制过技能：冲突文件必须向用户确认（覆盖/保留/另存）
3. 重复执行 init-harness.sh：零副作用，有变更时向用户确认

## 2. 方案
- 状态检测：fresh / initialized（marker 文件 .agents/.harness-flow-installed）/ existing
- 受管目录冲突检测：逐文件 cmp，列出"目标已存在且内容不同"清单
- 冲突策略：交互确认（/dev/tty，支持 HARNESS_FLOW_ANSWER 注入供测试）+ --force / --skip-existing 旗标；非交互无旗标时安全中止并给出指引
- AGENTS.md 冲突：保留(默认)/覆盖/另存 AGENTS.md.harness 三选
- 幂等保证：重跑无变更时只校验注册并提示"无需操作"

## 3. 验证
语法 → dry-run → 三场景端到端（fresh/existing/re-run）→ 幂等快照对比 → 关键词扫描
