---
name: integration-test
description: 服务端集成测试——验证多模块协作链路，含数据库、缓存、消息队列等中间件的真实交互。
---

# 服务端集成测试

## 0. 环境自适应

检测 Docker/测试环境可用性；不可用时输出 SKIP 不阻塞。

## 1. 测试范围

- **service → DB**：CRUD 操作正确性，事务回滚验证
- **service → Cache**：缓存命中/失效/穿透场景
- **service → MQ**：消息发送与消费的端到端一致性
- **跨服务调用**：内部 API 调用的超时、重试、熔断

## 2. 实现指南

按项目实际模块在 `.agents/quality-gate/l2-integration/run-l2-integration.sh` 中注册测试函数。骨架已提供模块数组 + 通过率阈值框架。

## 3. 输出

- PASS/FAIL 汇总，通过率 ≥ 90% 为 PASS
