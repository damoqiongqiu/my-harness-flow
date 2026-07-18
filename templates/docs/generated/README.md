# 生成物快照

Schema、API 定义、数据库 ER 图、代码统计等可读生成物快照。`generated/` 的内容可由自动化工具更新。

## 1. 示例

| 文件 | 来源 | 更新方式 |
|------|------|---------|
| `schema.sql` | 数据库导出 | CI 定时任务 |
| `api.json` | OpenAPI 提取 | 构建脚本 |
| `er-diagram.mermaid` | ER 图生成 | make target |
