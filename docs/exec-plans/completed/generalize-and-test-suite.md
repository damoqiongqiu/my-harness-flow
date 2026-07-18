# generalize-and-test-suite

- **档位**：Full（涉及 ci-scripts 测试套件 + installer + 多技能，核心模块升档）
- **分支**：`feat/generalize-and-test-suite`
- **阶段**：已完成（2026-07-17 12:55）

## 1. 范围（按"充分泛化"原则裁剪）
1. 收编 CI 脚本 unittest 套件 → .github/harness-tests/（56 文件，内部旧 marker/目录名全部中性化），加框架自用 ci.yml（不分发）
2. 修 finish-task 悬空引用（scripts/db/export-schema.sh → 条件化通用措辞）
3. templates/docs/bugs/ 补 _template-bug.md
4. installer 生成 .cursor/rules/agents.mdc（Cursor 接入，只补缺）
5. AGENTS.md.template + 框架 AGENTS.md 补「知识检索」段（泛化措辞）
6. 技能残留的中间件绑定措辞泛化（diagnose 的 MySQL/Redis/Kafka、quality-gate 的 Docker）
7. templates/docs/README.md 文档地图；scenarios README 注明可扩展层

## 2. 不做（泛化原则排除）
- issue-triage/config.json 示例（labels 项目绑定，由 bootstrap-issue-config 按仓库生成）
- design-docs 三件套大骨架（模板膨胀）
- 上游 4 篇方法论长文（暂缓）

## 3. 验证
测试套件全绿 → 安装端到端 + 幂等 → 关键词扫描 → py 全量编译
