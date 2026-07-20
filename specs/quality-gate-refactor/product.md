# quality-gate 目录重构 — 产品 Spec

**状态**: ✅ 已交付 | **创建**: 2026-07-20

## 问题
- 早期 `tests/scenarios/` 与项目原生 `test/` 目录冲突（如 Flutter）
- `quality-gate/` 暴露在项目根目录，用户困惑
- `scenarios/` 中间目录冗余

## 方案
`tests/scenarios/l[1-5]` → `.agents/quality-gate/l[1-5]`

## 验收
- [x] 全新 install → `.agents/quality-gate/` 正确创建
- [x] 升级 0.4.x → `.agents/quality-gate/` + 旧文件保留
- [x] demo-nextjs / demo_flutter / demo-springboot 全部适配
- [x] L1-L5 CI 全绿
