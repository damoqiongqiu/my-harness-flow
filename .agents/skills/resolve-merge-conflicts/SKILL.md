---
name: resolve-merge-conflicts
description: 通过仅提取未解决路径、冲突块和紧凑 diff（而非加载完整文件到上下文），解决 Git 合并冲突。当 merge、rebase、cherry-pick 或 stash pop 因冲突停止时使用，或当 `git status` 显示未合并路径时使用，或当文件包含冲突标记时使用。
---

# 解决合并冲突

## 1. 概览

在不打开完整文件的情况下解决冲突，除非紧凑视图不够用。从摘要开始，然后逐个检查冲突文件。

## 2. 工作流

1. 从摘要开始。

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py
```

使用摘要识别哪些文件未解决、存在哪些索引阶段，以及每个文件包含多少文本块。

2. 深入查看单个文件。

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py --file path/to/file
```

优先使用此方法而非读取整个文件。脚本只打印附近上下文、每个块的 `ours` / `base` / `theirs` 区域，以及 `ours` 和 `theirs` 之间的紧凑 unified diff。

3. 解决文件。

- 在适当时，用 `git checkout --ours -- path/to/file` 或 `git checkout --theirs -- path/to/file` 整体接受某一方。
- 否则直接编辑文件并移除冲突标记。
- 仅在紧凑输出不足以决定正确合并时才读取更多文件内容。

4. 重新检查未解决文件。

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py
git diff --name-only --diff-filter=U
```

5. 验证解决方案。

- 确保没有未合并路径残留。
- 确保已解决文件中没有 `<<<<<<<`、`=======` 或 `>>>>>>>` 标记残留。
- 运行涉及区域的针对性测试、构建或 linter。
- 暂存已解决的文件。

## 3. 命令

### 3.1 仅摘要

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py
```

### 3.2 单个文件详情

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py --file path/to/file
```

### 3.3 所有冲突文件的详情

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py --all
```

### 3.4 JSON 输出

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py --file path/to/file --json
```

### 3.5 调整输出大小

```bash
python3 .agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py \
  --file path/to/file \
  --context 3 \
  --max-lines 60
```

## 4. 说明

- 在直接打开冲突文件前使用脚本。
- 一次解决一个文件以保持上下文紧凑。
- 预期基于标记的文本冲突和索引级冲突（如 add/add 或 modify/delete）。脚本会汇总两者，当工作树文件没有冲突标记时退回到索引阶段预览。
