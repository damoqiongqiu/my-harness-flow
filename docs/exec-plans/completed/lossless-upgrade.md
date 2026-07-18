# 无损升级机制（lossless-upgrade）

- **档位**：Full（installer 核心模块，> 200 行，涉及升级路径）
- **分支**：feat/lossless-upgrade
- **阶段**：实现中

## 1. 目标

框架版本更新后重跑安装器，绝不破坏使用方内容：

1. 版本化：VERSION + CHANGELOG.md + marker 记录 version=
2. manifest：安装时记录受管文件 sha256 基线（.agents/.harness-flow-manifest）
3. 三态升级：未定制→自动更新；已定制→新版另存 *.harness；已废弃→报告不删
4. --force 语义收紧：只覆盖未定制文件
5. 无 manifest 的旧安装回退现有确认流程（向后兼容）

## 2. 附带修复

- 测试/验证的临时产物一律落系统临时目录（$TMPDIR），排查此前 tmp* 目录落在仓库根目录的根因

## 3. 验证方式

Full 档：bash -n / dry-run / 全新安装 / 幂等重跑 / 升级三场景模拟 / py 编译 / 品牌中性扫描，全部在 $TMPDIR 执行
