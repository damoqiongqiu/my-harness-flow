# adaptive-skills — 技能环境自适应降级

**档位**: Standard  
**分支**: feat/adaptive-skills  
**阶段**: 实现中  
**目标**: 8 个技能添加 capability check，本地/远程双环境零报错走通

## 改动清单

| # | 技能 | 改动 |
|---|------|------|
| 1 | git-push | 检测 remote → 无时跳过推送，成功退出 |
| 2 | create-pr | 检测 gh + remote → 无时跳过，提示 |
| 3 | create-issue | 检测 gh → 无时跳过，提示本地替代 |
| 4 | finish-task | 子步骤各自降级，本身不做额外改动 |
| 5 | bootstrap-issue-config | 检测 gh → 无时跳过，提示 |
| 6 | diagnose-ci-failures | 检测 gh → 无时跳过，提示 |
| 7 | quality-gate | 检测测试脚本存在性 → 无时跳过对应层 |
| 8 | diagnose | CI 委托已自行降级，本地部分不变 |
