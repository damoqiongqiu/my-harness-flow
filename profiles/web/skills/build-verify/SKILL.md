---
name: build-verify
description: 前端构建验证——检查项目能否成功 build，输出产物体积、依赖审计、TypeScript 类型检查。
---

# 构建验证

## 0. 环境自适应

需 Node.js + 包管理器（npm/yarn/pnpm）可用。

## 1. 验证清单

- [ ] **TypeScript 类型检查**：`tsc --noEmit` 零错误
- [ ] **Lint 检查**：ESLint/Prettier 零错误
- [ ] **生产构建**：`npm run build` 成功退出
- [ ] **产物体积**：关键 bundle 不超过阈值
- [ ] **依赖审计**：`npm audit` 无高危漏洞

## 2. 实现指南

```bash
npm run lint
npm run build
npx tsc --noEmit
```

在 `quality-gate/l1-smoke/health-check.sh` 中添加对应检查。

## 3. 输出

- PASS/FAIL 汇总 + 体积变化对比
