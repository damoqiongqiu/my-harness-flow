# 框架自身测试（吃狗粮）

my-harness-flow 用自己定义的 L1-L5 分层来验证自身。

## 运行

```bash
# 全量回归
bash tests/scenarios/l5-regression/run-l5-regression.sh

# 单层
bash tests/scenarios/l1-smoke/health-check.sh
bash tests/scenarios/l2-integration/run-l2-integration.sh
```

## 分层

| 层 | 检查内容 | 通过标准 |
|----|---------|---------|
| L1 | bash -n + CLI 帮助 + py_compile + 品牌中性 + 文件完整性 | 0 Fail |
| L2 | 安装/幂等/dry-run/status/upgrade/模板差异/profile/uninstall | 通过率 ≥ 90% |
| L3 | 全生命周期（安装 + web profile → 自检 → 卸载 → 清理） | 0 Fail |
| L4 | 硬编码密码 + API key + 品牌中性扫描 | 0 Fail |
| L5 | 串联 L1-L4 | 0 Fail |

> 本目录是框架自身的测试，不会分发给目标项目。
> 目标是 `templates/tests/scenarios/`，安装时复制到用户仓库。
