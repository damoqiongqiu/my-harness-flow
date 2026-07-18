# IssueID 识别示例

从以下常见形式识别 issue ID：

- 纯数字：`123`
- hash 形式：`#123`
- issue 表述：`issue 123`、`issue #123`、`IssueID 123`、`IssueID: #123`
- GitHub issue URL：`https://github.com/<owner>/<repo>/issues/123`
- GitHub PR URL（仅当用户明确将其标识为任务 issue 时）：`https://github.com/<owner>/<repo>/pull/123`
- 仓库简写：`<owner>/<repo>#123`
- 分支式引用：`issue-123`、`issue/123`、`<type>/<short-desc>-123`

如果出现多个数字，优先选择明确描述为 issue 或任务 ID 的那个。如果仍然模糊，请用户选择。
