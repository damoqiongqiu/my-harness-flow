# CLI 子命令化（cli-subcommands）

- **档位**：Full（installer 核心模块自动升档）
- **分支**：feat/cli-subcommands
- **阶段**：实现中

## 1. 目标

my-harness-cli.sh 增加 git 风格子命令，让用户意图可显式表达：

| 命令 | 行为 |
|------|------|
| `install` | 安装（全新/老项目接入） |
| `upgrade` / `update` | 升级（要求已安装，manifest 三态） |
| `register` | 仅技能软链注册（等价旧 --register-only） |
| `status` | 新增：显示安装版本/manifest/差异摘要 |
| `version` | 显示框架版本 |
| `help` | 帮助 |

## 2. 兼容性

- 不带子命令 + 旧 flags → 保持原自动判定行为（零破坏）
- usage 重写为命令分组式

## 3. 验证

Full 档：bash -n / 各子命令 e2e / 旧用法回归 / 幂等 / $TMPDIR 全程
