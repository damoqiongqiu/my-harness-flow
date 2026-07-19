# 创建 React+NextJS 示例工程 + harness 集成测试 — 覆盖性验证

**档位**: Full  
**分支**: feat/demo-nextjs  
**阶段**: 实现中  
**目标**: 在平级目录创建 Next.js 项目，安装 harness --profile web，跑通完整的 start-task → implement → quality-gate → finish-task 链条。

## 改动清单

| # | 类别 | 文件 | 内容 |
|---|------|------|------|
| 1 | feat | ../demo-nextjs/ (新仓库) | Next.js 14 项目骨架 |
| 2 | feat | ../demo-nextjs/ | 安装 my-harness-flow --profile web |
| 3 | feat | ../demo-nextjs/ | 实现一个任务管理小功能 |
| 4 | test | ../demo-nextjs/ | 跑 quality-gate L1-L5 验证 |

## 验证计划

- [x] harness install --profile web 成功
- [x] start-task 定档 + 创建分支
- [x] 实现功能 + quality-gate
- [x] finish-task 归档
- [x] 本地 L5 通过
