# <任务简称> — <一句话描述>

**档位**: Light / Standard / Full  
**分支**: <type>/<short-desc>  
**阶段**: 实现中 / 已完成  
**目标**: <一句话说明这次要达成什么>

<!-- 以下字段仅在 start-task 阶段填写：
  **specs**: <关联 spec 路径，如 specs/issue-42/product.md>
  **issue**: <关联 issue 链接或编号，如 #42>
  **创建时间**: YYYY-MM-DD
  **预计影响**: <文件数> 文件, <约行数> 行
-->

## 改动清单

<!-- 用表格列出每个要改的文件和改什么，让 reviewer 一看就懂 -->

| # | 类别 | 文件 | 内容 |
|---|------|------|------|
| 1 | feat | src/xxx.ts | <改动说明> |
| 2 | test | tests/xxx.test.ts | <测试说明> |

## 验证计划

<!-- 按定档列出要跑的验证命令 -->

- [ ] `bash -n` / lint
- [ ] 单元测试
- [ ] 端到端安装 / 集成测试

## 完成记录

<!-- finish-task 时填写 -->

- commit: `<hash>`
- 完成时间: YYYY-MM-DD
- 备注:
