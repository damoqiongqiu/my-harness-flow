---
name: e2e-test
description: 前端 E2E 浏览器测试——用 Playwright/Cypress 验证真实浏览器中的用户流程。
---

# E2E 浏览器测试

## 0. 环境自适应

需浏览器自动化工具（Playwright/Cypress）已安装。

## 1. 测试场景

- **核心用户流程**：登录 → 浏览 → 下单 → 支付（或项目等价流程）
- **多页面导航**：路由跳转、参数传递、浏览器后退
- **网络异常**：API 失败时的错误处理 UI
- **响应式**（可选）：不同视口下的布局正确性

## 2. 实现指南

```bash
# Playwright
npx playwright test

# Cypress
npx cypress run
```

在 `quality-gate/l3-e2e/` 中注册场景。

## 3. 输出

- 场景通过率 + 失败截图/录像
