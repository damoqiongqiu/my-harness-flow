---
name: simulator-manage
description: 移动端模拟器管理——启动/停止 iOS Simulator 或 Android Emulator，验证设备可用性。
---

# 模拟器管理

## 0. 环境自适应

检测 Xcode（iOS）/ Android SDK（Android）/ Flutter SDK 可用性；不可用时跳过。

## 1. 操作

- **iOS**：列出可用模拟器，启动指定设备，检查启动状态
- **Android**：列出 AVD，启动模拟器，等待 boot 完成
- **Flutter**：`flutter devices` 查看已连接设备

```bash
# iOS
xcrun simctl list devices
xcrun simctl boot "iPhone 16"

# Android
emulator -list-avds
emulator -avd Pixel_8 -no-window
adb wait-for-device

# Flutter（跨平台统一入口）
flutter devices
flutter emulators --launch Pixel_8   # Android
open -a Simulator                     # iOS（macOS）
```

## 2. 输出

- 设备就绪状态 + 超时处理
