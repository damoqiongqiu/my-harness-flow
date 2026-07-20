# Specs

按主题或 issue 拆分的产品和技术 spec。由 `write-product-spec` / `write-tech-spec` 技能生成，`spec-driven-implementation` / `start-task` 读取作为实现输入。

## 1. 目录结构

```
specs/
  _template-product.md   # 产品 spec 模板（新建时复制）
  _template-tech.md      # 技术 spec 模板（新建时复制）
  <topic>/               # 无 issue 跟踪时按主题命名（如 user-auth/）
    product.md           # 产品规格：用户可见行为、不变量、验收标准
    tech.md              # 技术规格：实现计划、数据流、风险与验证
  issue-<N>/             # 有 GitHub issue 跟踪时按 issue 编号命名
    product.md
    tech.md
```

## 2. 命名规则

- 有 issue → `issue-<N>/`（CI 的 create-spec-from-issue workflow 依赖此约定）
- 无 issue → `<topic>/`，小写连字符命名（如 `order-batch-cancel/`）
- 只需产品 spec 或只需技术 spec 时，另一个文件可省略

## 3. 何时写 spec

**任何 `docs/exec-plans/active/` 下的 exec-plan 都必须有对应 spec。** L1 质量门禁会检查这项约束。

| 任务规模 | spec 要求 |
|----------|----------|
| Full / Standard | `product.md` + `tech.md` |
| Light（bug 修复 / 小重构） | 至少 `product.md`（记录问题 + 修复描述） |

> 即使一行 bug 修复，也写一条 spec：它会留在仓库里，开发者可以 review、复盘、追溯。Agent 跳过 spec 直接改代码是最常见的质量滑坡起点。

## 4. 生命周期

1. 复制对应模板到目标目录，按模板内注释填写
2. 审查：`review-spec-local` 技能（本地）或 review-spec workflow（CI）
3. 实现：`spec-driven-implementation` 驱动，spec 与代码在同一 PR 内保持同步更新
4. 实现改变了预期行为时，**必须回头更新 spec**，保持与实际交付一致
