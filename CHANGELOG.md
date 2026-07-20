# Changelog

## [0.6.0] - 2026-07-20

### Added
- **文档格式校验**: L1 §5 扩展为 spec/work-journal/bug 格式检查，不符合模板时 WARN 不阻塞
- **review-pr-local 验证**: prepare_local_review_inputs.py 在 demo-springboot 实测可用
- **review-spec-local 验证**: prepare_issue_spec_context.py 编译通过


## [0.5.0] - 2026-07-20

### Breaking
- **`tests/` → `.agents/quality-gate/`**：门禁脚本重命名并隐藏到 `.agents/`，避免与框架原生 `test/` 冲突。升级时旧根目录文件保留，手动 `rm`
- **L1/L2 脚本移入 `.agents/quality-gate/`**：从项目根目录移走，根目录零入侵
- **模板扁平化**：移除 `scenarios/` 中间目录，`l1-smoke/` 等直接在 `quality-gate/` 下

### Added
- **Spec 门禁**：L1 §5 Spec 完整性检查——任何活跃 exec-plan 必须有对应 `specs/<topic>/`。Light 任务至少 `product.md`
- **finish-task 合并后校验**：步骤 3.5——squash merge 后 poll GitHub API，pull 后校验 specs 完整性，缺则自动恢复
- **backend demo 项目**：`demo-springboot`（Spring Boot 3.3 + Task CRUD API + 9 测试），三 profile 全部实测验证
- **mobile demo 项目**：`demo_flutter`（Flutter 3.24 + harness mobile profile L1 6/6）

### Fixed
- **`.github/harness-tests` 泄漏**：`sync_managed_dirs` 的 `find .github/` 全扫未排除，56 个 Python 测试文件泄漏到用户项目
- **squash merge 丢 spec**：`git pull` 比 GitHub 异步落盘更快导致 specs/ 丢失，`finish-task` 新增校验步骤
- **L3 E2E profile**：`--profile web`（依赖 node_modules）→ `--profile backend`（零依赖），CI 不再报 L1-self-check
- **L2/L3/L4 残留路径**：`scenarios/` 子目录扁平化后多处引用未同步
- **Platform 检测**：GitLab 自建实例 API 探测（HTTP+HTTPS 双协议），`install_profile` 目标目录修正

### Verified
- 四项目双平台：demo-nextjs / demo_flutter / demo-springboot / my-harness-flow，GitHub + GitLab 同步
- GitHub Actions CI：L1+L2+L3+L4+L5 全绿
- 升级路径：v0.4.x → v0.5.0 零中断

## [0.4.1] - 2026-07-20

### Added
- **GitLab 双平台完整适配**：CLI `detect_platform()` API 探测（HTTP+HTTPS）、`glab` 自动检测提示、`.gitlab-ci.yml` 模板（L1-L5 五层）且安装时自动复制
- **目标项目路径规则**：8 个技能加注文档归属（exec-plan/spec/work-journal/bug/report → 目标项目，非 framework），AGENTS.md.template 新增 §0 路径约定表
- **安装时自定义 docs 检测**：已有非 harness 的 `docs/` 时交互确认（y=接受整合 / n=退出），`--yes` 自动接受
- **GitLab CI Pipeline 模板**：`templates/.gitlab-ci.yml.template`，GitLab 平台安装时自动复制
- **升级时 Profile 差异检测**：`install --profile` 时同时扫描 `profiles/` 目录，报告未选中 profile 的文件差异

### Changed
- **Web profile L1 默认启用**：`tsc --noEmit`、`eslint`、`jest` 从注释改为默认执行，无工具时 SKIP（不阻塞）
- **Jest/ESLint 检测改文件判断**：从 `npx --version` 改为 `[ -x node_modules/.bin/jest ]`，避免 npx 自动下载误判
- **技能文档 GitLab 适配**：`create-issue`（glab issue create）、`create-pr`（glab mr create）新增双 CLI 命令分支

### Verified
- demo-nextjs 项目上的全量覆盖测试（16/18 能力验证，L5 全绿）
- GitHub + 内网 GitLab（10.x.x.x）双 remote 推送实测
- `gh` + `glab` CLI 双平台 issue/MR 创建实测

## [0.4.0] - 2026-07-18

### Added
- 领域 Profile 机制：`--profile backend/web/mobile` 一键安装领域专属技能（各 3 个）+ 测试脚本 + 路由规则
- L1 健康检查 lint 代码风格段：后端（Go/Python/Java/Node）/ 前端（TypeScript/ESLint）/ 移动端（Swift/ktlint/Flutter）
- `--yes` 非交互模式：全流程零提示，所有确认自动选安全默认（保留已有），适配 CI/CD 长程任务
- 模板升级差异检测：升级时自动报告框架已有更新但本地保留的模板文件
- README 典型用法章节：全新项目/老项目/生命周期/CI 四场景示例

### Changed
- 移动端 Profile 扩展 Flutter 全链路（flutter analyze / dart format / flutter test / flutter build）
- 技能双平台 CLI：`gh` ↔ `glab`（GitHub ↔ GitLab），从 git remote URL 自动判定
- README 章节重编号 4→9

## [0.3.0] - 2026-07-18

### Added
- `uninstall` 子命令：基于 manifest 精确清受管文件与软链，定制文件保留
- 技能环境自适应降级：7 个技能在缺少 gh/glab/remote/测试脚本时优雅跳过，不阻断编排链
- GitHub / GitLab 双平台自适应：5 个 CLI 依赖技能从 git remote URL 自动判定平台并选择 gh/glab
- 模板骨架补齐：新增 exec-plan / design-doc / pitfall / work-journal 四种文档模板
- 测试脚本骨架重写：L1 健康检查（四类结构化检查）+ L2 集成测试（模块数组 + 通过率阈值）+ L3/L4/L5 改进
- README 新增 `HARNESS_FLOW_ANSWER` 自动化安装文档

### Changed
- README 测试数更新：369 → 501
- 技能名称统一：PR → PR/MR，GitHub Actions → CI/CD Pipeline
- 安装器技能注册前增加 `~/.workbuddy/skills/` 副作用提示

### Fixed
- 安装器错误信息补 `--target` 指引
- CHANGELOG md 编号数 61 → 71

## [0.2.0] - 2026-07-18

### Added
- 版本化：VERSION 文件 + CHANGELOG.md
- 安装器写入受管文件 sha256 清单（`.agents/.harness-flow-manifest`），支持无破坏升级
- 升级三态判定：未定制文件自动更新，定制文件新版另存 `*.harness`，废弃文件报告不自动删除
- `--force` 语义收紧：只覆盖未定制文件，定制文件降级为另存
- CLI 子命令化：`install / upgrade / register / status / version / help`，兼容旧 flags
- docs 模板目录补齐：design-docs/generated/product-specs/references/reports
- 框架自身工作目录骨架初始化（吃狗粮）

### Changed
- **安装器改名**：`init-harness.sh` → `my-harness-cli.sh`（生命周期全覆盖）
- marker 格式扩展，新增 `version=` 字段
- 全仓库 71 个 md 文档标题统一层级编号（`## 1. / ### 1.1`）

### Fixed
- 测试临时目录改用系统临时目录，不再落在仓库根目录
- macOS bash 3.2 兼容性修复（`declare -A` / 进程替换 / 多字节字符 bug）

## [0.1.0] - 初始版本

### Added
- init-harness.sh 安装器：受管目录同步 + 模板实例化 + 多 agent 技能注册
- 21 个任务级技能 + 6 个编排技能
- 17 个 CI 技能 + 12 个受管 workflow
- 项目模板（AGENTS.md 路由表 + docs/test/specs 骨架）
