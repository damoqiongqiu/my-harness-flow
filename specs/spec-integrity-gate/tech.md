# Spec 完整性门禁 — 技术 Spec

**关联**: specs/spec-integrity-gate/product.md

## 实现
- 三个 profile L1 均新增 §5 Spec 完整性段
- 逻辑: glob `docs/exec-plans/active/*.md` → 检查 `specs/<topic>/` 目录
- WARN 不阻塞 PASS（非 FAIL）

## 配套改动
- `templates/specs/README.md`: "何时写 spec" 规则收紧
- `finish-task` 步骤 3.5: merge 后校验 specs 完整性
