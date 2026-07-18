# 执行计划追踪

## 1. active/
当前进行中的长任务状态文件，可跨会话恢复。由 `start-task` 创建，`session-start` 读取。

## 2. completed/
已完成的任务计划，保留历史上下文。由 `finish-task` 归档。
