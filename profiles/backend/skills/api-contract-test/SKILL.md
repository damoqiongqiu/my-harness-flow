---
name: api-contract-test
description: 服务端 API 契约测试——验证接口的请求/响应格式、状态码、边界条件，确保 API 不出现意外的 breaking change。
---

# API 契约测试

## 0. 环境自适应

无特定平台依赖，需目标服务可用。

## 1. 测试策略

- **正常路径**：合法输入 → 预期输出 + 正确状态码
- **边界值**：空参数、超长字符串、特殊字符、null/undefined
- **异常输入**：缺少必填字段、无效 token、过期 token
- **幂等性**：同一请求重复发送 → 相同结果

## 2. 实现指南

<!-- 按项目实际情况实现 -->

```bash
# 示例：用 curl 验证 /api/users 接口
curl -sf http://localhost:3000/api/users | jq '.'
```

## 3. 输出

- PASS/FAIL 汇总，FAIL 时附带请求体和响应差异
- 发现 breaking change 时标记为阻塞项
