# quality-gate 目录重构 — 技术 Spec

**关联**: specs/quality-gate-refactor/product.md

## 改动范围
- `templates/tests/` → `templates/.agents/quality-gate/`（扁平化）
- `managed_dirs` 新增 `.agents/quality-gate`
- `sync_managed_dirs` 排除 `harness-tests`
- L1/L2 脚本从根目录移入 `.agents/quality-gate/`
- `install_profile()` 目标目录修正

## 路径迁移
```
tests/scenarios/l1-smoke/ → .agents/quality-gate/l1-smoke/
quality-gate/scenarios/   → .agents/quality-gate/l[1-5]/
l1-health-check.sh (root) → .agents/quality-gate/l1-health-check.sh
```

## 引用更新
- 24 文件批量路径替换（sed）
- CI workflow: `.github/workflows/ci.yml`
- skills: quality-gate / diagnose / build-verify 等
- AGENTS.md template 示例命令

## 踩坑
- sync_managed_dirs 的 `find .github/` 全扫未排除 harness-tests（56 文件泄漏）
- ROOT 路径深度 `../../..` → `../..` （扁平化后少一层）→ `../../..`（移入 .agents/ 又多一层）
- L3 E2E 的 `test-dir` 检查未同步（`scenarios/` → 直接 `quality-gate/`）
