---
name: db-migration-verify
description: 数据库迁移验证——检查 migration 脚本的可逆性、幂等性、数据完整性，防止迁移导致的数据丢失或服务中断。
---

# 数据库迁移验证

## 0. 环境自适应

需数据库连接可用（通过环境变量或配置）。

## 1. 验证清单

- [ ] **up/down 可逆**：依次执行 up → down → up，最终状态一致
- [ ] **幂等性**：同一 migration 重复执行不报错
- [ ] **空数据安全**：空表/空数据库上迁移不失败
- [ ] **已有数据兼容**：在含数据的表上添加列/索引不锁表
- [ ] **回滚验证**：down 操作在实际环境能成功执行

## 2. 实现指南

```bash
# 示例：在测试数据库中跑 migration 循环验证
DB_URL=postgres://test:test@localhost:5432/test_db
# 1. 执行 up
# 2. 验证 schema
# 3. 执行 down
# 4. 验证 schema 已回滚
# 5. 执行 up 确认可重跑
```

## 3. 输出

- 每个 migration 文件的验证结果（PASS/FAIL + 原因）
