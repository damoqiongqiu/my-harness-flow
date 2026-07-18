---
name: build-sign
description: 移动端构建与签名验证——检查项目构建产物、签名配置、分发准备。
---

# 构建与签名验证

## 0. 环境自适应

需 Xcode（iOS）/ Android SDK（Android）/ Flutter SDK 可用。

## 1. 验证清单

- [ ] **Debug 构建**：能成功编译运行
- [ ] **Release 构建**：配置文件正确，无编译警告
- [ ] **签名有效**：provisioning profile / keystore 未过期
- [ ] **包体积**：IPA/APK 不超过阈值
- [ ] **依赖完整性**：CocoaPods/Gradle/pubspec 依赖锁定一致

## 2. 实现指南

```bash
# iOS
xcodebuild -workspace YourApp.xcworkspace -scheme YourApp archive

# Android
./gradlew assembleRelease
./gradlew lint

# Flutter
flutter build apk --release
flutter build ios --release --no-codesign
flutter build web --release      # Web 输出
```

## 3. 输出

- PASS/FAIL 汇总 + 包体变化 + Flutter Web 产物（如有）
