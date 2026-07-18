# Changelog

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
