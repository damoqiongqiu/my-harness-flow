# gh-glab-dual-platform — GitHub/GitLab 双平台适配

**档位**: Standard  
**分支**: feat/gh-glab-dual-platform  
**阶段**: 实现中  
**目标**: 5 个 CLI 依赖技能增加 `gh/glab` 双平台检测 + 术语统一

## 改动清单

| # | 技能 | 改动 |
|---|------|------|
| 1 | create-pr | gh/glab 检测，PR/MR 双术语 |
| 2 | create-issue | gh/glab 检测 |
| 3 | bootstrap-issue-config | gh/glab 检测 |
| 4 | diagnose-ci-failures | gh/glab 检测，CI/Pipeline 术语 |
| 5 | git-push | 已平台无关，补平台自适应引用 |
