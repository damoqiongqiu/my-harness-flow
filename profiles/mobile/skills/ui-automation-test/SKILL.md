---
name: ui-automation-test
description: 移动端 UI 自动化测试——用 XCTest（iOS）/ Espresso（Android）在模拟器上运行 UI 测试。
---

# UI 自动化测试

## 0. 环境自适应

需模拟器已启动 + 对应的测试框架已配置。

## 1. 测试场景

- **核心页面展示**：主要界面元素是否正确渲染
- **手势交互**：滑动、点击、长按等交互响应
- **导航流程**：Tab 切换、页面跳转、返回
- **权限弹窗**：相机/定位/通知等权限请求处理

## 2. 实现指南

```bash
# iOS
xcodebuild test -scheme YourApp -destination 'platform=iOS Simulator,name=iPhone 16'

# Android
./gradlew connectedAndroidTest
```

## 3. 输出

- 测试通过率 + 失败截图
