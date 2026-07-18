# Commit 消息示例

## 1. 好的示例

### 1.1 Bug 修复

```text
fix(router): avoid nil worker panic during reconnect
```

```text
fix(auth): preserve session after token refresh race
```

### 1.2 功能

```text
feat(editor): add slash command search for recent notes
```

### 1.3 重构

```text
refactor(runtime): split worker lifecycle management
```

### 1.4 性能

```text
perf(cache): reduce kv allocator fragmentation
```

带正文：

```text
perf(cache): reduce kv allocator fragmentation

Reuse fixed-size cache pages during mixed prefill/decode
workloads to reduce allocator churn and tail latency.
```

### 1.5 文档

```text
docs(api): clarify webhook retry semantics
```

### 1.6 测试

```text
test(queue): cover retry ordering under backpressure
```

---

## 2. 不好的示例

避免以下类型的消息：

```text
update
misc fixes
wip
changes
stuff
final
more work
```

这些消息过于模糊，对审查、回滚或未来调试没有帮助。

---

## 3. 边界示例

### 3.1 保持在一起

Bug 修复 + 直接相关的测试：

```text
fix(parser): reject invalid nested frontmatter blocks
```

包含：
- parser 修复
- 一个或多个证明修复的测试

### 3.2 拆分开

重构 + bug 修复：

Commit 1：

```text
refactor(parser): extract token boundary helpers
```

Commit 2：

```text
fix(parser): preserve offsets for escaped delimiters
```

### 3.3 将文档清理与功能开发分开

Commit 1：

```text
feat(cli): add --json output for session status
```

Commit 2：

```text
docs(cli): remove outdated examples from status section
```

---

## 4. scope 示例

在明显时使用具体的 scope：

- `fix(router): ...`
- `perf(cache): ...`
- `refactor(runtime): ...`
- `docs(config): ...`
- `test(scheduler): ...`

如果 scope 不清楚，可省略：

```text
fix: prevent duplicate retry scheduling on restart
```

## 5. Issue 链接示例

### 5.1 自动关闭 footer

```text
fix(router): avoid nil worker panic during reconnect

Fixes #123
```

仅当 commit 应该关闭 issue 时使用。

### 5.2 关联 issue footer

```text
docs(skill): clarify branch naming safeguards

Refs #123
```

用于相关、部分、准备性、仅文档、仅测试、仅清理或模糊的工作。当 issue ID 仅来自分支名时，优先使用此方式。

### 5.3 内联风格

```text
fix(router): avoid nil worker panic during reconnect (#123)
```

仅当仓库规范要求时使用内联风格。
