---
name: component-test
description: 前端组件测试——验证 React/Vue 等组件的行为、渲染、事件处理，保证 UI 逻辑正确。
---

# 组件测试

## 0. 环境自适应

需 Node.js + 项目测试框架（Jest/Vitest/Playwright component）可用。

## 1. 测试策略

- **渲染验证**：组件正确渲染，DOM 结构符合预期
- **交互行为**：点击/输入/提交等事件触发正确的回调
- **状态变更**：props/state 变更后 UI 正确更新
- **边界情况**：空数据、加载态、错误态、超长文本
- **无障碍**（可选）：aria 属性、键盘导航

## 2. 实现指南

```bash
# 示例：运行组件测试
npm test -- --coverage
# 或
npx vitest run
```

## 3. 输出

- 测试通过率 + 覆盖率报告
