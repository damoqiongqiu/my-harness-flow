# 领域 Profile

每个 Profile 包含：
- `skills/` — 领域专属技能（SKILL.md），安装时注册到各 agent
- `AGENTS.md.append` — 追加的路由规则与硬规则
- `l1-health-check.sh` — L1 健康检查骨架（含领域工具链探测）
- `l2-integration.sh` — L2 单元测试骨架（模块数组注册）

## 当前 Profile

| Profile | 适用场景 | 技能数 |
|---------|---------|--------|
| `backend` | 服务端（Go/Python/Java/Node.js） | 3 |
| `web` | Web 前端（React/Vue/Next.js 等） | 3 |
| `mobile` | 移动端（iOS/Android/Flutter） | 3 |

## 用法

```bash
./my-harness-cli.sh install --target /path/to/repo --profile backend
./my-harness-cli.sh install --target /path/to/repo --profile web
./my-harness-cli.sh install --target /path/to/repo --profile mobile
```

不加 `--profile` 时只安装 21 个通用核心技能。

## 添加新 Profile

1. 在本目录下创建 `<profile-name>/`，参考现有结构
2. 技能 SKILL.md 必须含 `name` 和 `description` frontmatter
3. 安装器会自动发现 `profiles/<name>/` 并安装
