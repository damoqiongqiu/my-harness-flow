日报 — 2026-07-20
项目: my-harness-flow AI 工程框架

一句话总结：框架一天内完成 v0.4.1→v0.6.0 两次大版本迭代，三项核心门禁落地、三项泄漏/踩坑修复、三个 profile 全部实测验证，GitHub Actions CI 全绿，GitHub + GitLab 双平台同步。

一、Quality-Gate 目录重构
将 tests/scenarios/ 重命名为 .agents/quality-gate/，解决与 Flutter/Next.js 原生 test/ 目录的命名冲突。L1/L2 脚本从项目根目录移入 .agents/，用户根目录实现零入侵。涉及 24 个文件的路径同步更新。

二、Spec 完整性 + 格式校验门禁
L1 质量门禁新增 §5 文档格式校验，分三层：spec 文件必须含状态声明（**状态**）和关联引用（**关联**），work-journal 必须按 YYYY-MM-DD.md 命名，bug 报告必须含"复现步骤"或"根因"段。格式不符时输出 WARN 不阻塞流程。web/mobile/backend 三个 profile 全覆盖。

三、Finish-Task 合并后校验
发现 GitHub squash merge 存在异步落盘问题：gh pr merge 返回成功但 commit 尚未生成，此时 git pull 会拿到旧 HEAD 导致 specs/ 文件丢失。新增步骤 3.5：poll GitHub API 确认 mergedAt 非空后再 pull，pull 后校验 specs/ 完整性，缺失则从分支 commit 自动恢复。

四、框架泄漏修复
sync_managed_dirs 的 find .github/ 全量扫描未排除自用测试目录，导致 .github/harness-tests/ 下 56 个 Python 测试文件泄漏到用户项目。已通过 --exclude 规则封堵，三个 demo 项目清理完毕。

五、后端 Profile 验证
新建 demo-springboot 项目（Spring Boot 3.3 + Task CRUD API + 9 单元测试），完整走通 spec→实现→quality-gate→PR→merge 全链路，完成 backend profile 实测验证。

六、框架自合规
框架自身补齐 specs/ 目录（quality-gate-refactor、spec-integrity-gate 双文档）和 work-journal 日报记录，实现"吃自己的狗粮"。

七、验证覆盖
  - my-harness-flow: L5 全绿 / GitHub CI 通过
  - demo-nextjs (Next.js 15 / web profile): L1 PASS / 升级零中断
  - demo_flutter (Flutter 3.24 / mobile profile): L1 6/6 / flutter analyze+test 全绿
  - demo-springboot (Spring Boot 3.3 / backend profile): L1 4/4 / mvn test 9/9
  全部项目 GitHub + GitLab 双 remote 同步。

八、技术踩坑
  - GitHub squash merge 是异步的，mergedAt 字段查询是唯一的可靠完成信号
  - 目录层级变更时 ROOT 路径计算需逐层验证（涉及 L1-L4 四个脚本）
  - find .github/ 全扫需显式排除非分发目录

九、下一步
  - GitLab Runner 内网 CI 部署
  - 后端 profile 三项技能实测
