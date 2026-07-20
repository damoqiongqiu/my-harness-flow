#!/usr/bin/env bash
set -euo pipefail

# my-harness-flow 安装器
#
# 把整套 AI 开发流装进目标仓库：
#   1. 受管目录同步：.agents/skills、.agents/contracts、.github/{skills,agents,scripts,workflows}
#   2. 模板实例化（只补缺，绝不静默覆盖已有文件）：AGENTS.md、docs/、.agents/quality-gate/
#   3. 多 agent 技能注册：
#      - WorkBuddy   → 用户级 ~/.workbuddy/skills/（harness 只扫用户级，不扫项目级）
#      - Claude Code → 项目级 .claude/skills/（agentskills.io 规范）
#      - Gemini CLI  → 项目级 .gemini/skills/（agentskills.io 规范）
#      - Codex CLI   → 原生扫描 .agents/skills/，无需注册
#
# 三种目标状态的行为约定：
#   - 全新空工程：静默完整安装，零提问
#   - 老项目（已有 AGENTS.md / 自有文件 / 定制过技能）：冲突文件逐一向用户确认
#   - 已初始化过、重复执行：零副作用；检测到差异（本地定制或框架更新）时向用户确认

usage() {
  cat <<'USAGE'
用法: my-harness-cli.sh <命令> [选项]

命令:
  install     安装 harness 到目标仓库（全新安装或老项目接入）
  upgrade     升级已安装的 harness（按 sha256 基线三态判定，定制永不丢失）
  uninstall   从目标仓库移除 harness（基于 manifest 清单清受管文件与软链）
  register    仅注册技能软链（幂等，可反复执行）
  status      显示目标仓库的安装状态（版本 / 升级基线 / 差异摘要）
  version     显示框架版本号
  help        显示本帮助

通用选项:
  --target <path>   目标仓库路径，默认为当前目录。
  --dry-run         只打印将执行的动作与冲突清单，不写任何文件、不提问。
  --yes             非交互模式：所有确认问题自动选择安全默认（保留已有、不删、不覆盖）。

install 专属选项:
  --no-templates    跳过模板实例化（只同步技能与 CI 资产）。
  --profile <name>  安装领域 Profile（backend / web / mobile），追加专属技能与路由规则。
  --force           仅旧安装（无 manifest）生效：冲突不提问，直接覆盖（CI 场景）。
  --skip-existing   仅旧安装（无 manifest）生效：冲突不提问，保留已有只新增。

upgrade 行为（存在 .agents/.harness-flow-manifest 基线时）:
  逐文件按 sha256 基线三态判定，全程无需人工介入：
    未定制（本地 == 安装基线）→ 自动更新为框架新版
    已定制（本地 != 安装基线）→ 本地保留，框架新版另存为 *.harness
    已废弃（基线有、新框架已删）→ 仅报告，不自动删除
  --force / --skip-existing 在此模式下不生效（定制永不被覆盖）。

冲突处理（无 manifest 的旧安装 / 首次装进老项目时）:
  受管目录（.agents/.github）中"目标已存在且内容与框架不同"的文件视为冲突。
  默认交互确认：
    [o] 全部覆盖  [s] 全部保留只新增  [a] 中止
  非交互环境（无 TTY）且未指定 --force / --skip-existing 时安全中止。
  AGENTS.md 等模板文件永不静默覆盖；已有时可选 保留 / 覆盖 / 另存为 *.harness。

示例:
  ./my-harness-cli.sh install --target /path/to/repo    # 安装
  ./my-harness-cli.sh install --target /path/to/repo --profile backend  # 安装 + 后端 Profile
  ./my-harness-cli.sh upgrade --target /path/to/repo    # 无损升级
  ./my-harness-cli.sh status --target /path/to/repo     # 查看安装状态
  ./my-harness-cli.sh install --target /path/to/repo --dry-run   # 安装预览
  ./my-harness-cli.sh register --target /path/to/repo   # 只补技能软链
  ./my-harness-cli.sh version                           # 查看框架版本

兼容: 不带命令直接使用旧选项（如 --target/--register-only）仍然有效，
      行为为自动判定（未装则安装、已装则升级）。
USAGE
}

fail() { printf 'my-harness-cli.sh: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$(pwd)"
dry_run=false
register_only=false
with_templates=true
conflict_policy="ask"   # ask | force | skip
non_interactive=false
profile_name=""
marker_rel=".agents/.harness-flow-installed"
manifest_rel=".agents/.harness-flow-manifest"

# 读取框架版本号（VERSION 文件）
get_version() {
  local vf="$script_dir/VERSION"
  if [ -f "$vf" ]; then
    head -1 "$vf" | tr -d ' \t\n\r'
  else
    echo '0.0.0'
  fi
}

# 受管目录对（相对路径，源与目标同构）
managed_dirs=".agents/skills .agents/quality-gate .agents/contracts .github/skills .github/agents .github/scripts .github/workflows"

# ── 子命令解析（首个非选项参数）────────────────────────────────
# auto = 兼容模式（无子命令的旧用法：未装则安装、已装则升级）
command="auto"
if [ "$#" -gt 0 ]; then
  case "$1" in
    install|upgrade|update|register|status|version|help|uninstall)
      command="$1"; shift
      [ "$command" = "update" ] && command="upgrade"
      ;;
    -*) : ;;  # 选项开头 → 兼容模式
    *) fail "未知命令: $1（可用: install / upgrade / uninstall / register / status / version / help）" ;;
  esac
fi

case "$command" in
  version) printf 'my-harness-flow %s\n' "$(get_version)"; exit 0 ;;
  help) usage; exit 0 ;;
  register) register_only=true ;;
esac

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      [ "$#" -ge 2 ] || fail "--target 需要一个路径参数"
      target_dir="$2"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    --register-only) register_only=true; shift ;;
    --no-templates) with_templates=false; shift ;;
    --force) conflict_policy="force"; shift ;;
    --skip-existing) conflict_policy="skip"; shift ;;
    --yes) non_interactive=true; shift ;;  # 非交互：所有确认自动选安全默认
    --profile)
      [ "$#" -ge 2 ] || fail "--profile 需要一个名称参数（如 backend / web / mobile）"
      profile_name="$2"; shift 2 ;;
    --version) printf 'my-harness-flow %s\n' "$(get_version)"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "未知参数: $1" ;;
  esac
done

[ -d "$target_dir" ] || fail "目标路径不是目录: $target_dir"
target_dir="$(cd "$target_dir" && pwd)"
[ "$target_dir" = "$script_dir" ] && fail "目标不能是 my-harness-flow 源码树自身（用 --target 指定其他目录）"

# ── 平台检测 ─────────────────────────────────────────────────────
detect_platform() {
  local remote_url
  remote_url="$(cd "$target_dir" && git remote get-url origin 2>/dev/null)" || remote_url=""
  case "$remote_url" in
    *gitlab*|*git.selfhosted*) printf 'gitlab' ;;
    *github*) printf 'github' ;;
    *)
      # 自建 GitLab 域名可能不含 gitlab：尝试 API 探测（HTTP + HTTPS）
      local api_url probe
      api_url="$(echo "$remote_url" | sed 's|://[^@]*@|://|' | sed 's|\(://[^/]*\).*|\1/api/v4/version|')"
      probe="$(curl -sf "$api_url" 2>/dev/null)" || true
      if [ -z "$probe" ]; then
        api_url="$(echo "$api_url" | sed 's|^http://|https://|')"
        probe="$(curl -sf "$api_url" 2>/dev/null)" || true
      fi
      if echo "$probe" | grep -qE '"version"|"message"'; then
        printf 'gitlab'
      else
        printf 'unknown'
      fi
      ;;
  esac
}
platform=$(detect_platform)
# 重新获取 remote_url 用于后续检查（detect_platform 内是 local 变量）
remote_url="$(cd "$target_dir" && git remote get-url origin 2>/dev/null)" || remote_url=""
[ "$platform" = "gitlab" ] && ! command -v glab >/dev/null 2>&1 && info "检测到 GitLab remote，建议安装 glab CLI: brew install glab"
# 自建 GitLab 注意：如果 HTTP（非 HTTPS），认证时加 --api-protocol http
[ "$platform" = "gitlab" ] && [ -n "$remote_url" ] && echo "$remote_url" | grep -q "^http://" && info "GitLab 使用 HTTP: glab auth login 时请加 --api-protocol http"
# GitLab 平台：自动安装 .gitlab-ci.yml 模板
if [ "$platform" = "gitlab" ] && [ -f "$script_dir/templates/.gitlab-ci.yml.template" ] && [ ! -f "$target_dir/.gitlab-ci.yml" ]; then
  cp "$script_dir/templates/.gitlab-ci.yml.template" "$target_dir/.gitlab-ci.yml"
  info "已安装 .gitlab-ci.yml（GitLab CI Pipeline 模板）"
fi

# ── 交互工具 ─────────────────────────────────────────────────────
# 从 /dev/tty 读取用户选择；无 TTY 时返回空（由调用方决定安全默认）。
# HARNESS_FLOW_ANSWER 环境变量可注入答案（自动化测试用）。
ask_user() {
  local prompt="$1" default="${2:-}" reply=""
  # --yes 非交互模式：直接返回默认值
  if [ "$non_interactive" = true ]; then
    [ -n "$default" ] && printf '%s\n' "  (--yes) 自动选择: $default" >&2
    printf '%s' "$default"
    return 0
  fi
  if [ -n "${HARNESS_FLOW_ANSWER:-}" ]; then
    printf '%s' "$HARNESS_FLOW_ANSWER"
    return 0
  fi
  # 用真实 open 测试 TTY 可用性（[ -r /dev/tty ] 在无 TTY 环境下也可能为真）
  if ( : < /dev/tty ) 2>/dev/null; then
    printf '%s' "$prompt" > /dev/tty
    IFS= read -r reply < /dev/tty || reply=""
  fi
  printf '%s' "$reply"
}

# ── 状态检测 ─────────────────────────────────────────────────────
# fresh: 目标不含任何我们关心的路径 → 静默安装
# initialized: 存在 marker → 重复执行场景
# existing: 其他（老项目）→ 冲突需确认
detect_state() {
  if [ -f "$target_dir/$marker_rel" ]; then
    printf 'initialized'
  elif [ -e "$target_dir/AGENTS.md" ] || [ -d "$target_dir/.agents" ] \
    || [ -d "$target_dir/.github/skills" ] || [ -d "$target_dir/docs" ] \
    || [ -d "$target_dir/tests" ]; then
    printf 'existing'
  else
    printf 'fresh'
  fi
}

# ── 受管目录冲突检测 ─────────────────────────────────────────────
# 输出：目标中已存在且内容与框架不同的文件相对路径（每行一个）
list_managed_conflicts() {
  local d f rel
  for d in $managed_dirs; do
    [ -d "$target_dir/$d" ] || continue
    [ -d "$script_dir/$d" ] || continue
    while IFS= read -r f; do
      rel="${f#"$script_dir"/}"
      case "$rel" in *.DS_Store) continue ;; esac
      if [ -f "$target_dir/$rel" ] && ! cmp -s "$f" "$target_dir/$rel"; then
        printf '%s\n' "$rel"
      fi
    done < <(find "$script_dir/$d" -type f)
  done
}

# ── 第一步：受管目录同步 ─────────────────────────────────────────
copy_dir() {
  local src="$1" dest="$2"; shift 2
  if [ "$dry_run" = true ]; then
    info "将同步 ${src#"$script_dir"/} -> ${dest#"$target_dir"/}"
  else
    mkdir -p "$dest"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$@" "$src/" "$dest/"
    else
      # Windows Git Bash / 无 rsync 环境 → cp -r 降级
      cp -r "$src"/* "$dest/" 2>/dev/null || true
    fi
  fi
}

# 跨平台软链：优先 ln -s，失败时降级为 cp -r
safe_link() {
  local src="$1" dst="$2"
  if ln -s "$src" "$dst" 2>/dev/null; then
    return 0
  fi
  # Windows 非管理员 / core.symlinks=false → 拷贝目录
  cp -r "$src" "$dst" 2>/dev/null
}

sync_managed_dirs() {
  command -v rsync >/dev/null 2>&1 || fail "需要 rsync"
  [ -d "$script_dir/.agents/skills" ] || fail "源 .agents/skills 缺失"

  # 辅助：查 manifest 中某路径的基线哈希（空=不在manifest中）
  baseline_from_manifest() {
    awk -v p="$2" '{ h = $1; sub(/^[^ ]*  /, ""); if ($0 == p) { print h; exit } }' "$1"
  }

  local manifest="$target_dir/$manifest_rel"

  # ── manifest 存在 → 三态升级 ──────────────────────────────────
  if [ -f "$manifest" ]; then
    local fw_file fw_rel fw_hash tg_hash baseline
    local auto=0 harness=0 deprec=0 newfiles=0
    # 文件列表落系统临时目录（绝不写进目标仓库）；
    # 不用 < <(find …|sort)：bash 3.2 在该写法上有解析缺陷
    local file_list
    file_list="$(mktemp "${TMPDIR:-/tmp}/harness-flow-files.XXXXXX")"
    find "$script_dir/.agents" "$script_dir/.github" -type f | sort > "$file_list"

    # 遍历框架每个受管文件（排除不分发项）
    while IFS= read -r fw_file; do
      fw_rel="${fw_file#"$script_dir"/}"
      case "$fw_rel" in
        */.DS_Store|.github/workflows/ci.yml|*.github/skills/*-repo/*|*harness-tests/*|*harness-tests*) continue ;;
      esac
      tg_file="$target_dir/$fw_rel"
      fw_hash="$(sha256_this "$fw_file")"
      baseline="$(baseline_from_manifest "$manifest" "$fw_rel")"

      if [ ! -f "$tg_file" ]; then
        # 没装过 → 安装
        if [ "$dry_run" = true ]; then
          info "[manifest] 新文件: $fw_rel"
        else
          mkdir -p "$(dirname "$tg_file")"
          cp "$fw_file" "$tg_file"
        fi
        newfiles=$((newfiles + 1))
      elif [ -n "$baseline" ]; then
        tg_hash="$(sha256_this "$tg_file")"
        if [ "$tg_hash" = "$baseline" ]; then
          # 本地未改动 → 安全自动更新
          if [ "$dry_run" = true ]; then
            info "[manifest] 自动更新: ${fw_rel}（未定制）"
          else
            mkdir -p "$(dirname "$tg_file")"
            cp "$fw_file" "$tg_file"
          fi
          auto=$((auto + 1))
        else
          # 本地定制过 → 新版另存 *.harness，本地保留
          if [ "$dry_run" = true ]; then
            info "[manifest] 定制冲突: $fw_rel -> ${fw_rel}.harness（本地保留）"
          else
            if ! cp "$fw_file" "${tg_file}.harness" 2>/dev/null; then
              info "✗ 无法写入: ${tg_file}.harness"
            fi
          fi
          harness=$((harness + 1))
        fi
      fi
    done < "$file_list"
    rm -f "$file_list"

    # 检测废弃文件：manifest 里有但框架已经删了的
    while IFS= read -r line; do
      local h p
      h="${line%%  *}"
      p="${line#*  }"
      [ -z "$h" ] && continue; [ -z "$p" ] && continue
      # 框架中是否还存在
      fw_file="$script_dir/$p"
      if [ ! -f "$fw_file" ] && [ -f "$target_dir/$p" ]; then
        case "$p" in
          .github/workflows/ci.yml|*.github/skills/*-repo/*) continue ;;
        esac
        info "  ⚠ 废弃文件（框架已删除，本地保留）: $p"
        deprec=$((deprec + 1))
      fi
    done < "$manifest"

    info "[manifest 升级] 新文件 $newfiles  自动更新 $auto  定制另存 $harness  废弃报告 $deprec"
    return 0
  fi

  # ── 无 manifest（旧安装/首次）→ 现有 cmp 冲突流程 ─────────────
  local conflicts n extra_flags=""
  conflicts="$(list_managed_conflicts)"
  n=0; [ -n "$conflicts" ] && n="$(printf '%s\n' "$conflicts" | wc -l | tr -d ' ')"

  if [ "$n" -gt 0 ]; then
    info ""
    info "检测到 $n 个受管文件与框架版本不同（可能是本地定制，也可能是框架更新）："
    printf '%s\n' "$conflicts" | head -20 | sed 's/^/  - /'
    [ "$n" -gt 20 ] && info "  ...（其余 $((n - 20)) 个略）"

    if [ "$dry_run" = true ]; then
      info "[dry-run] 实际执行时将按 --force/--skip-existing 或交互选择处理上述冲突。"
    else
      local choice="$conflict_policy"
      if [ "$choice" = "ask" ]; then
        if [ "$non_interactive" = true ]; then
          choice="skip"  # --yes 模式默认保留已有
        else
          choice="$(ask_user '处理方式 [o]全部覆盖 / [s]全部保留只新增 / [a]中止（默认 a）: ')"
          case "$choice" in
            o|O) choice="force" ;;
            s|S) choice="skip" ;;
            ""|a|A) choice="abort" ;;
            *) choice="abort" ;;
          esac
        fi
      fi
      case "$choice" in
        force) info "→ 覆盖全部冲突文件（框架版本为准）" ;;
        skip)  info "→ 保留已有文件，只新增缺失文件"; extra_flags="--ignore-existing" ;;
        abort) fail "已中止。可用 --force（覆盖）或 --skip-existing（保留）重试，或先自行备份冲突文件。" ;;
      esac
    fi
  fi

  local d
  for d in $managed_dirs; do
    [ -d "$script_dir/$d" ] || continue
    # *-repo 为本仓库自进化的 companion 技能，不分发；ci.yml 为框架自用
    # shellcheck disable=SC2086
    copy_dir "$script_dir/$d" "$target_dir/$d" --exclude ci.yml --exclude .DS_Store --exclude '*-repo' $extra_flags
  done
}

# ── 第二步：模板实例化（只补缺，冲突逐一确认）────────────────────
install_file_if_missing() {
  local src="$1" dest="$2"
  [ -e "$dest" ] && return 0
  if [ "$dry_run" = true ]; then
    info "将创建 ${dest#"$target_dir"/}"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  fi
}

install_agents_md() {
  local tpl="$script_dir/templates/AGENTS.md.template"
  local dst="$target_dir/AGENTS.md"

  # 1. 无 AGENTS.md → 全新创建
  local project_name; project_name="$(basename "$target_dir")"
  if [ ! -e "$dst" ]; then
    if [ "$dry_run" = false ]; then
      sed "s|{{PROJECT_NAME}}|${project_name}|g; s|{{PROJECT_DESCRIPTION}}||g" "$tpl" > "$dst"
      info "提示: 已生成 AGENTS.md"
    fi
    return 0
  fi

  # 2. 已有 harness 标记段 → 原地替换内容
  if grep -q 'my-harness-flow: begin' "$dst" 2>/dev/null; then
    if grep -q '{{PROJECT_NAME}}\|{{PROJECT_DESCRIPTION}}' "$dst" 2>/dev/null; then
      # 标记段内有占位符 → 原地替换（不移动、不删用户内容）
      if [ "$dry_run" = false ]; then
        local htmp; htmp="$(mktemp "${TMPDIR:-/tmp}/hf-harness-XXXXXX")"
        sed -n '/<!-- my-harness-flow: begin -->/,/<!-- my-harness-flow: end -->/p' "$tpl" \
          | sed "s|{{PROJECT_NAME}}|${project_name}|g; s|{{PROJECT_DESCRIPTION}}||g; s|{{MODULE_1}}||g; s|{{MODULE_2}}||g; s|{{CORE_MODULES}}||g; s|{{PROJECT_HARD_RULE_1}}||g" > "$htmp"
        python3 "$script_dir/.agents/scripts/replace_harness_section.py" "$dst" "$htmp"
        rm -f "$htmp"
        info "提示: 检测到旧版 harness 内容，已原位刷新"
      fi
      return 0
    fi
    [ "$dry_run" = false ] && info "提示: AGENTS.md 已含 harness 路由规则，跳过"
    return 0
  fi

  # 3. 用户自有的 AGENTS.md → 静默前置插入 harness 内容
  if [ "$dry_run" = true ]; then
    info "提示: AGENTS.md 已存在（无 harness 标记），将前置插入 harness 路由规则"
    return 0
  fi

  # 提取模板中 harness section
  local harness_section
  harness_section="$(sed -n '/<!-- my-harness-flow: begin -->/,/<!-- my-harness-flow: end -->/p' "$tpl" \
    | sed "s|{{PROJECT_NAME}}|${project_name}|g; s|{{PROJECT_DESCRIPTION}}||g; s|{{MODULE_1}}||g; s|{{MODULE_2}}||g; s|{{CORE_MODULES}}||g; s|{{PROJECT_HARD_RULE_1}}||g" \
    | grep -vxF '')"

  # 前置插入
  local tmp="$(mktemp "${TMPDIR:-/tmp}/hf-agents-XXXXXX")"
  { echo "$harness_section"; echo ""; cat "$dst"; } > "$tmp"
  mv "$tmp" "$dst"
  info "提示: harness 路由规则已前置插入，你的内容在下方原样保留。"
}

install_templates() {
  local f rel
  local updated_template_list="" updated_count=0

  # ── 已有项目结构检测 ─
  # 目标已有 docs/ 目录且非 harness 首次安装 → 提示用户
  if [ -d "$target_dir/docs" ] && [ "$state" != "initialized" ]; then
    # 检查 docs/ 下是否有非 harness 模板的文件
    local harness_templates="exec-plans work-journal bugs reports plan references design-docs generated product-specs"
    local has_custom=0
    for entry in "$target_dir/docs"/*; do
      [ ! -e "$entry" ] && continue
      local name="$(basename "$entry")"
      if ! echo "$harness_templates" | grep -qw "$name" && [ "$name" != "README.md" ]; then
        has_custom=1; break
      fi
    done
    if [ "$has_custom" -eq 1 ]; then
      info "⚠  检测到目标项目已有自定义 docs/ 目录结构"
      info "⚠  安装后将追加 harness 子目录（exec-plans/ work-journal/ 等），可能混入已有结构"
      if [ "$conflict_policy" = "skip" ]; then
        info "→ --skip-existing 模式：跳过模板安装以避免目录混杂"
        return 0
      fi
      if [ "$non_interactive" = true ]; then
        info "→ --yes 模式：自动接受整合，追加 harness 子目录到现有 docs/"
      else
        local answer
        answer="$(ask_user '继续安装？（y=接受整合 / n=退出）[y/n] ')" || answer="n"
        case "$answer" in
          y|Y|yes|YES) info "→ 接受整合，追加 harness 子目录到现有 docs/" ;;
          *) info "→ 已退出。如需迁移，备份 docs/ 后重新安装。"; exit 0 ;;
        esac
      fi
    fi
  fi

  install_agents_md

  # CLAUDE.md：真实文件，用 @AGENTS.md 导入语法指向统一指引
  # （不用软链：部分编辑器/同步盘/Windows 环境打不开软链，且 git 在
  #   core.symlinks=false 时会把软链检出成纯文本）
  if [ ! -e "$target_dir/CLAUDE.md" ] && [ ! -L "$target_dir/CLAUDE.md" ]; then
    if [ "$dry_run" = true ]; then
      info "将创建 CLAUDE.md（@AGENTS.md 导入）"
    else
      printf '# CLAUDE.md\n\n本仓库的 agent 指引统一维护在 AGENTS.md：@AGENTS.md\n' > "$target_dir/CLAUDE.md"
    fi
  fi

  # Cursor 接入：.cursor/rules/agents.mdc 指向 AGENTS.md（只补缺）
  if [ ! -e "$target_dir/.cursor/rules/agents.mdc" ]; then
    if [ "$dry_run" = true ]; then
      info "将创建 .cursor/rules/agents.mdc（Cursor 读取 AGENTS.md）"
    else
      mkdir -p "$target_dir/.cursor/rules"
      cat > "$target_dir/.cursor/rules/agents.mdc" <<'MDC'
---
alwaysApply: true
---

# Agent Guidance

遵循仓库根目录 `AGENTS.md` 中的共享指引。

任务级工作流在 `.agents/skills/*/SKILL.md`。当请求点名某个 skill 或明显匹配其用途时，使用对应 skill。
MDC
    fi
  fi

  # docs/ 、.agents/quality-gate/ 与 specs/ 骨架：逐文件只补缺
  # 已有文件时检测框架是否有更新，静默报告不覆盖
  while IFS= read -r f; do
    rel="${f#"$script_dir"/templates/}"
    case "$rel" in *.gitkeep) mkdir -p "$(dirname "$target_dir/$rel")" 2>/dev/null || true; continue ;; esac
    case "$rel" in AGENTS.md.template) continue ;; esac  # harness 施工图，不安装到用户项目
    local dst="$target_dir/$rel"
    if [ -e "$dst" ]; then
      # 文件已存在，检查内容和当前版本是否一致
      if ! cmp -s "$f" "$dst"; then
        updated_template_list="${updated_template_list}  - ${rel}"$'\n'
        updated_count=$((updated_count + 1))
      fi
      continue
    fi
    if [ "$dry_run" = true ]; then
      info "将创建 ${rel}"
    else
      mkdir -p "$(dirname "$dst")"
      cp "$f" "$dst"
    fi
  done < <(find "$script_dir/templates/docs" "$script_dir/templates/.agents/quality-gate" "$script_dir/templates/specs" -type f; find "$script_dir/templates" -maxdepth 1 -type f 2>/dev/null)

  # Profile 文件差异检测（路径映射: profiles/<name>/X → target/X）
  while IFS= read -r f; do
    rel="${f#"$script_dir/profiles/"}"
    local dst="$target_dir/${rel#*/}"   # 去掉 profiles/<name>/ 前缀
    if [ -e "$dst" ]; then
      if ! cmp -s "$f" "$dst"; then
        updated_template_list="${updated_template_list}  - Profile ${rel}"$'\n'
        updated_count=$((updated_count + 1))
      fi
    fi
  done < <(find "$script_dir/profiles" -type f 2>/dev/null)

  # 报告可更新的模板文件
  if [ "$updated_count" -gt 0 ]; then
    info ""
    info "检测到 $updated_count 个模板文件框架已有更新（本地文件已保留）："
    printf '%s' "$updated_template_list"
    info "如需更新为框架新版，手动删除以上文件后重跑安装即可。"
  fi

  # 保持骨架脚本可执行
  if [ "$dry_run" = false ]; then
    find "$target_dir/.agents/quality-gate" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
  fi
}

# ── 第三步：多 agent 技能软链注册 ────────────────────────────────
register_agent_skills() {
  local src="$target_dir/.agents/skills"
  local subdir label d name
  local total_linked=0 total_skipped=0 total_cleaned=0 total_warned=0

  # 注册表："label:skills目录"（以 / 开头视为绝对路径 = 用户级）
  set -- \
    "WorkBuddy:$HOME/.workbuddy/skills" \
    "Claude Code:.claude/skills" \
    "Gemini CLI:.gemini/skills"

  if [ ! -d "$src" ]; then
    info "跳过注册: $src 不存在（先运行完整安装）"
    return 0
  fi

  # 提示用户级副作用
  if [ "$dry_run" = false ]; then
    info "提示: 技能将注册到 $HOME/.workbuddy/skills/ 等目录，涉及当前用户环境。"
  fi

  # 遗留迁移：清理历史版本注册到项目级 .workbuddy/skills/ 的软链（该目录不在扫描范围）
  local legacy_dst="$target_dir/.workbuddy/skills"
  if [ -d "$legacy_dst" ]; then
    for d in "$legacy_dst"/*; do
      [ -L "$d" ] || continue
      case "$(readlink "$d")" in
        "$src"/*|"$src")
          if [ "$dry_run" = true ]; then
            info "将移除遗留项目级软链: ${d#"$target_dir"/}"
          else
            rm "$d"
          fi ;;
      esac
    done
    [ "$dry_run" = true ] || rmdir "$legacy_dst" 2>/dev/null || true
  fi

  for entry; do
    label="${entry%%:*}"
    subdir="${entry#*:}"
    local dst
    case "$subdir" in
      /*) dst="$subdir" ;;
      *)  dst="$target_dir/$subdir" ;;
    esac
    local linked=0 skipped=0 cleaned=0 warned=0

    [ "$dry_run" = false ] && mkdir -p "$dst"

    # 清理悬空软链
    if [ -d "$dst" ]; then
      for d in "$dst"/*; do
        [ -L "$d" ] || continue
        if [ ! -e "$d" ]; then
          if [ "$dry_run" = true ]; then
            info "将移除悬空软链: $d"
          else
            rm "$d"
          fi
          cleaned=$((cleaned + 1))
        fi
      done
    fi

    for d in "$src"/*/; do
      name="$(basename "$d")"
      if [ ! -f "$d/SKILL.md" ]; then
        [ "$warned" -eq 0 ] && info "  [$label] 警告: $name 缺少 SKILL.md，跳过"
        warned=$((warned + 1))
        continue
      fi
      if [ -e "$dst/$name" ]; then
        skipped=$((skipped + 1))
        continue
      fi
      if [ "$dry_run" = true ]; then
        info "将创建软链: $dst/$name -> .agents/skills/$name"
      else
        safe_link "${d%/}" "$dst/$name"
      fi
      linked=$((linked + 1))
    done

    info "  [$label] 新链 $linked, 已存在 $skipped, 清理死链 $cleaned, 缺 SKILL.md $warned"
    total_linked=$((total_linked + linked))
    total_skipped=$((total_skipped + skipped))
    total_cleaned=$((total_cleaned + cleaned))
    total_warned=$((total_warned + warned))
  done

  info "  [Codex CLI] 原生扫描 .agents/skills/，无需注册"
  info "注册完成: 合计 新链 $total_linked, 已存在 $total_skipped, 清理死链 $total_cleaned, 缺 SKILL.md $total_warned"
  if [ "$total_linked" -gt 0 ] && [ "$dry_run" = false ]; then
    info "提示: 各工具的技能列表在会话初始化时计算，需重开对应工具会话后新技能才会出现。"
  fi
}

write_marker() {
  [ "$dry_run" = true ] && return 0
  mkdir -p "$(dirname "$target_dir/$marker_rel")"
  {
    printf 'installed_at=%s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf 'source=%s\n' "$script_dir"
    printf 'version=%s\n' "$(get_version)"
  } > "$target_dir/$marker_rel"
}

# ── 受管文件校验 ──────────────────────────────────────────────────
# 跨平台 sha256：尝试 shasum（macOS）→ sha256sum（Linux）→ openssl
sha256_this() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  else
    openssl sha256 "$f" | awk '{print $NF}'
  fi
}

# 为当前安装的受管文件生成 sha256 清单（安装器基线）
write_manifest() {
  [ "$dry_run" = true ] && return 0
  local d f rel hash manifest="$target_dir/$manifest_rel"
  {
    for d in $managed_dirs; do
      [ -d "$target_dir/$d" ] || continue
      while IFS= read -r f; do
        [ -f "$f" ] || continue
        rel="${f#"$target_dir"/}"
        case "$rel" in *.DS_Store) continue ;; esac
        hash="$(sha256_this "$f")"
        printf '%s  %s\n' "$hash" "$rel"
      done < <(find "$target_dir/$d" -type f | sort)
    done
  } > "$manifest"
}

# ── status 命令 ──────────────────────────────────────────────────
show_status() {
  local marker="$target_dir/$marker_rel" manifest="$target_dir/$manifest_rel"
  info "框架版本:   $(get_version)（${script_dir}）"
  info "目标仓库:   $target_dir"
  if [ ! -f "$marker" ]; then
    info "安装状态:   未安装"
    info ""
    info "运行安装:   my-harness-cli.sh install --target $target_dir"
    return 0
  fi
  local iver iat
  iver="$(grep '^version=' "$marker" 2>/dev/null | cut -d= -f2- || true)"
  iat="$(grep '^installed_at=' "$marker" 2>/dev/null | cut -d= -f2- || true)"
  info "已装版本:   ${iver:-未知（旧版安装，无版本记录）}"
  info "安装时间:   ${iat:-未知}"
  if [ -f "$manifest" ]; then
    local mcount diffs
    mcount="$(wc -l < "$manifest" | tr -d ' ')"
    info "升级基线:   有（$mcount 个受管文件）→ 支持无损升级"
    diffs="$(list_managed_conflicts | grep -c . || true)"
    if [ "$diffs" -eq 0 ]; then
      info "受管文件:   与当前框架完全一致，无需升级"
    else
      info "受管文件:   $diffs 个与当前框架不同"
      info ""
      info "执行升级:   my-harness-cli.sh upgrade --target $target_dir"
      info "升级预览:   my-harness-cli.sh upgrade --target $target_dir --dry-run"
    fi
  else
    info "升级基线:   无（旧版安装）→ 升级将走冲突确认流程；成功升级一次后生成基线"
  fi
}

# ── uninstall ────────────────────────────────────────────────────
# 基于 manifest 清单清受管文件 + 软链，定制文件保留
uninstall_harness() {
  local marker="$target_dir/$marker_rel" manifest="$target_dir/$manifest_rel"
  local keep_count=0 del_count=0 link_count=0 skip_count=0

  [ -f "$marker" ] || fail "目标未安装 harness（缺 ${marker_rel}）"

  info "目标仓库: $target_dir"
  info ""

  # 确认（交互或 --force）
  if [ "$dry_run" = false ] && [ "$conflict_policy" != "force" ]; then
    local answer
    answer="$(ask_user '⚠ 将移除 harness 的受管文件与技能软链（定制/新增文件保留）。确认? [y/N] ' 'y')"
    case "$answer" in y|Y) : ;; *) info "已取消。" ; exit 0 ;; esac
  fi

  # 1. 移除受管文件（基于 manifest；定制文件保留）
  if [ -f "$manifest" ]; then
    while IFS= read -r line; do
      local hash path
      hash="${line%%  *}"
      path="${line#*  }"
      [ -z "$hash" ] && continue; [ -z "$path" ] && continue

      local f="$target_dir/$path"
      if [ -f "$f" ]; then
        local cur
        cur="$(sha256_this "$f")"
        if [ "$cur" = "$hash" ]; then
          if [ "$dry_run" = true ]; then
            info "  将删除（未定制）: $path"
          else
            rm "$f"
          fi
          del_count=$((del_count + 1))
        else
          # 本地定制过 → 保留
          if [ "$dry_run" = true ]; then
            info "  将保留（已定制）: $path"
          fi
          keep_count=$((keep_count + 1))
        fi
      else
        skip_count=$((skip_count + 1))
      fi
    done < "$manifest"
  else
    info "  (无 manifest，跳过受管文件清理)"
  fi

  # 2. 清理技能软链
  local d name
  for d in "$target_dir/.claude/skills" "$target_dir/.gemini/skills" "$HOME/.workbuddy/skills"; do
    [ -d "$d" ] || continue
    for name in "$d"/*; do
      [ -L "$name" ] || continue
      case "$(readlink "$name")" in
        "$target_dir/.agents/skills"/*)
          if [ "$dry_run" = true ]; then
            info "  将移除软链: ${name}"
          else
            rm "$name"
          fi
          link_count=$((link_count + 1)) ;;
      esac
    done
    # 清理空目录
    if [ "$dry_run" = false ]; then
      rmdir "$d" 2>/dev/null || true
    fi
  done

  # 3. 移除 marker 和 manifest
  if [ "$dry_run" = true ]; then
    info "  将移除: $marker_rel"
    info "  将移除: $manifest_rel"
  else
    rm -f "$marker" "$manifest"
  fi

  # 4. 清理空目录（受管目录 + agent 注册目录中可能已空的层级）
  if [ "$dry_run" = false ]; then
    for d in .agents/skills .agents/contracts .agents .github/skills .github/agents .github/scripts .github/workflows .github .claude/skills .claude .gemini/skills .gemini .cursor/rules .cursor; do
      [ -d "$target_dir/$d" ] || continue
      rmdir "$target_dir/$d" 2>/dev/null || true
    done
  fi

  info ""
  if [ "$dry_run" = true ]; then
    info "[dry-run] 将删除 $del_count 个受管文件, 保留 $keep_count 个定制文件, 跳过 $skip_count 个不存在文件, 移除 $link_count 个技能软链."
  else
    info "已删除 $del_count 个受管文件, 保留 $keep_count 个定制文件, 跳过 $skip_count 个不存在文件, 移除 $link_count 个技能软链."
    info "my-harness-flow 卸载完成。"
  fi
}

# ── Profile 安装 ──────────────────────────────────────────────────
install_profile() {
  [ -z "$profile_name" ] && return 0
  local profile_dir="$script_dir/profiles/$profile_name"
  [ -d "$profile_dir" ] || { info "提示: profile '$profile_name' 不存在，已跳过。可用: $(ls "$script_dir/profiles" 2>/dev/null | tr '\n' ' ')"; return 0; }

  # 1. 复制 profile 的测试脚本和 AGENTS.md.append
  if [ "$dry_run" = true ]; then
    info "--- Profile: $profile_name ---"
  fi

  local f rel
  while IFS= read -r f; do
    rel="${f#"$profile_dir"/}"
    case "$rel" in
      AGENTS.md.append) continue ;;  # 单独处理
      skills/*) continue ;;          # 单独注册
    esac
    if [ "$dry_run" = true ]; then
      info "  将创建 $rel（profile: $profile_name）"
    else
      case "$rel" in
        l1-health-check.sh|l2-integration.sh)
          mkdir -p "$target_dir/.agents/quality-gate"
          cp "$f" "$target_dir/.agents/quality-gate/$rel" ;;
        *)
          mkdir -p "$(dirname "$target_dir/$rel")"
          cp "$f" "$target_dir/$rel" ;;
      esac
    fi
  done < <(find "$profile_dir" -type f)

  # 2. 追加 AGENTS.md 路由规则
  local append_file="$profile_dir/AGENTS.md.append"
  if [ -f "$append_file" ] && [ -f "$target_dir/AGENTS.md" ]; then
    if grep -q "my-harness-flow profile:" "$target_dir/AGENTS.md" 2>/dev/null; then
      info "  AGENTS.md 已有 profile 追加内容，跳过"
    else
      if [ "$dry_run" = true ]; then
        info "  将追加 profile 路由规则到 AGENTS.md"
      else
        printf '\n' >> "$target_dir/AGENTS.md"
        cat "$append_file" >> "$target_dir/AGENTS.md"
        info "  → profile '$profile_name' 路由规则已追加到 AGENTS.md"
      fi
    fi
  fi

  # 3. 注册 profile 技能
  local profile_skills="$profile_dir/skills"
  if [ -d "$profile_skills" ] && [ -d "$target_dir/.agents/skills" ]; then
    for d in "$profile_skills"/*/; do
      local name
      name="$(basename "$d")"
      if [ ! -f "$d/SKILL.md" ]; then continue; fi
      if [ "$dry_run" = true ]; then
        info "  将安装 profile 技能: $name"
        continue
      fi
      # 复制到目标技能目录
      if [ ! -d "$target_dir/.agents/skills/$name" ]; then
        cp -r "$d" "$target_dir/.agents/skills/$name"
      fi
      # 注册到各 agent
      for agent_dir in "$target_dir/.claude/skills" "$target_dir/.gemini/skills" "$HOME/.workbuddy/skills"; do
        [ -d "$agent_dir" ] || continue
        [ -e "$agent_dir/$name" ] && continue
        safe_link "$target_dir/.agents/skills/$name" "$agent_dir/$name" 2>/dev/null || true
      done
    done
    info "  → profile '$profile_name' 技能已安装并注册"
  fi
}

# ── 主流程 ───────────────────────────────────────────────────────
case "$command" in
  status)
    show_status
    exit 0 ;;
  upgrade)
    [ -f "$target_dir/$marker_rel" ] || fail "目标未安装 harness（缺 ${marker_rel}），请先运行: my-harness-cli.sh install --target $target_dir" ;;
  uninstall)
    uninstall_harness
    [ "$dry_run" = true ] && info "dry-run 结束，未写任何文件。"
    exit 0 ;;
  install)
    if [ -f "$target_dir/$marker_rel" ]; then
      info "提示: 目标已安装过 harness，本次将按升级逻辑处理（等价 upgrade）。"
    fi ;;
esac

if [ "$register_only" = true ]; then
  register_agent_skills
  [ "$dry_run" = true ] && info "dry-run 结束，未写任何文件。"
  exit 0
fi

state="$(detect_state)"
case "$state" in
  fresh)
    info "目标状态: 全新工程 ${target_dir} -> 静默完整安装" ;;
  existing)
    info "目标状态: 已有内容的工程 ${target_dir} -> 冲突文件将逐一确认" ;;
  initialized)
    installed_at="$(grep '^installed_at=' "${target_dir}/${marker_rel}" 2>/dev/null | cut -d= -f2- || true)"
    info "目标状态: 已初始化过（${installed_at:-未知时间}）-> 重复执行保护生效"
    # 无任何差异时提前短路：只校验注册，零副作用
    if [ -z "$(list_managed_conflicts)" ]; then
      info "受管文件与框架版本完全一致，无需同步；仅校验技能注册。"
      [ "$with_templates" = true ] && install_templates
      install_profile
      register_agent_skills
      write_marker
      write_manifest
      [ "$dry_run" = true ] && info "dry-run 结束，未写任何文件。"
      exit 0
    fi ;;
esac

sync_managed_dirs
[ "$with_templates" = true ] && install_templates
install_profile
register_agent_skills
write_marker
write_manifest

if [ "$dry_run" = true ]; then
  info "dry-run 结束，未写任何文件。"
else
  info "my-harness-flow 安装完成。"
fi
