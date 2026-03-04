#!/usr/bin/env bash
# Claude Code statusline — reads JSON session data from stdin

data=$(cat)

# Parse fields from JSON
model_id=$(echo "$data" | jq -r '.model.id // "unknown"')
context_pct=$(echo "$data" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
lines_added=$(echo "$data" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$data" | jq -r '.cost.total_lines_removed // 0')
cwd=$(echo "$data" | jq -r '.workspace.current_dir // ""')
duration_ms=$(echo "$data" | jq -r '.cost.total_duration_ms // 0')
vim_mode=$(echo "$data" | jq -r '.vim.mode // ""')

# Git info
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
worktree=""
if [ -f "$cwd/.git" ]; then
  worktree=" "
fi

# Git status counts
if [ -n "$branch" ]; then
  git_status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(echo "$git_status" | grep -c '^[MADRC]' 2>/dev/null || echo 0)
  modified=$(echo "$git_status" | grep -c '^.[MD]' 2>/dev/null || echo 0)
  untracked=$(echo "$git_status" | grep -c '^??' 2>/dev/null || echo 0)
fi

# Model tier glyph (saves space vs full name)
case "$model_id" in
  *opus*)   model_glyph="◆ Opus" ;;
  *sonnet*) model_glyph="◇ Sonnet" ;;
  *haiku*)  model_glyph="○ Haiku" ;;
  *)        model_glyph="$model_id" ;;
esac

# Detect language/runtime version
lang=""
if [ -f "$cwd/package.json" ]; then
  node_ver=$(node -v 2>/dev/null)
  [ -n "$node_ver" ] && lang=" ${node_ver}"
elif [ -f "$cwd/Cargo.toml" ]; then
  rust_ver=$(rustc --version 2>/dev/null | awk '{print $2}')
  [ -n "$rust_ver" ] && lang=" ${rust_ver}"
elif [ -f "$cwd/go.mod" ]; then
  go_ver=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
  [ -n "$go_ver" ] && lang=" ${go_ver}"
elif [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/setup.py" ] || [ -f "$cwd/requirements.txt" ]; then
  py_ver=$(python3 --version 2>/dev/null | awk '{print $2}')
  [ -n "$py_ver" ] && lang=" ${py_ver}"
fi

# Context bar (10 chars wide)
filled=$((context_pct / 10))
empty=$((10 - filled))
bar=""
for ((i = 0; i < filled; i++)); do bar+="█"; done
for ((i = 0; i < empty; i++)); do bar+="░"; done

# Colors (catppuccin mocha)
green="\033[38;2;166;227;161m"
peach="\033[38;2;250;179;135m"
yellow="\033[38;2;249;226;175m"
blue="\033[38;2;137;180;250m"
lavender="\033[38;2;180;190;254m"
red="\033[38;2;243;139;168m"
teal="\033[38;2;148;226;213m"
text="\033[38;2;205;214;244m"
dim="\033[38;2;108;112;134m"
reset="\033[0m"

# Context bar color — warn early (quality degrades before limits)
if [ "$context_pct" -ge 80 ]; then
  bar_color="$red"
elif [ "$context_pct" -ge 60 ]; then
  bar_color="$peach"
elif [ "$context_pct" -ge 40 ]; then
  bar_color="$yellow"
else
  bar_color="$green"
fi

# Context warning label
ctx_label=""
if [ "$context_pct" -ge 80 ]; then
  ctx_label=" ⚠ reset"
elif [ "$context_pct" -ge 60 ]; then
  ctx_label=" compact soon"
elif [ "$context_pct" -ge 40 ]; then
  ctx_label=" watch"
fi

# Format duration
total_secs=$((duration_ms / 1000))
hours=$((total_secs / 3600))
mins=$(( (total_secs % 3600) / 60 ))
secs=$((total_secs % 60))
if [ "$hours" -gt 0 ]; then
  duration_fmt="${hours}h${mins}m"
elif [ "$mins" -gt 0 ]; then
  duration_fmt="${mins}m${secs}s"
else
  duration_fmt="${secs}s"
fi

# Net lines
net=$((lines_added - lines_removed))
if [ "$net" -gt 0 ]; then
  net_indicator="${green}↑${net}${reset}"
elif [ "$net" -lt 0 ]; then
  net_indicator="${red}↓${net#-}${reset}"
else
  net_indicator="${dim}=${reset}"
fi

# Short directory name (replace $HOME with ~)
dir_short=$(echo "$cwd" | sed "s|$HOME|~|")

# ── Plan usage tracking (Max5: 1000 msgs per 5hr window) ──
PLAN_MSG_LIMIT=1000
CACHE_FILE="/tmp/claude-statusline-usage.cache"
CACHE_TTL=30  # seconds

update_usage_cache() {
  local now_epoch cutoff_epoch cutoff_ts msg_count
  now_epoch=$(date +%s)
  cutoff_epoch=$((now_epoch - 18000))  # 5 hours ago
  cutoff_ts=$(date -u -r "$cutoff_epoch" +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -d "@$cutoff_epoch" +%Y-%m-%dT%H:%M:%S)

  # Count assistant messages across all projects in the last 5 hours
  msg_count=$(find "$HOME/.claude/projects" -name '*.jsonl' -mmin -300 -exec \
    jq -r "select(.type == \"assistant\" and .timestamp > \"$cutoff_ts\") | .timestamp" {} \; 2>/dev/null | wc -l | tr -d ' ')

  echo "${now_epoch} ${msg_count}" > "$CACHE_FILE"
  echo "$msg_count"
}

# Read from cache or refresh
plan_msgs=0
if [ -f "$CACHE_FILE" ]; then
  cache_data=$(cat "$CACHE_FILE")
  cache_epoch=$(echo "$cache_data" | awk '{print $1}')
  cache_msgs=$(echo "$cache_data" | awk '{print $2}')
  now_epoch=$(date +%s)
  if [ $((now_epoch - cache_epoch)) -lt "$CACHE_TTL" ]; then
    plan_msgs=$cache_msgs
  else
    plan_msgs=$(update_usage_cache)
  fi
else
  plan_msgs=$(update_usage_cache)
fi

plan_remaining=$((PLAN_MSG_LIMIT - plan_msgs))
[ "$plan_remaining" -lt 0 ] && plan_remaining=0
plan_pct=$((plan_msgs * 100 / PLAN_MSG_LIMIT))

# Plan usage color
if [ "$plan_pct" -ge 80 ]; then
  plan_color="$red"
elif [ "$plan_pct" -ge 60 ]; then
  plan_color="$peach"
elif [ "$plan_pct" -ge 40 ]; then
  plan_color="$yellow"
else
  plan_color="$green"
fi

# Reset countdown (time until 5hr window rolls)
now_epoch=$(date +%s)
# Align to 5hr blocks from midnight UTC
block_secs=18000
day_start=$(date -u -j -f '%Y-%m-%dT%H:%M:%S' "$(date -u +%Y-%m-%dT00:00:00)" +%s 2>/dev/null || date -u -d "$(date -u +%Y-%m-%d)" +%s)
elapsed_today=$((now_epoch - day_start))
current_block_start=$((day_start + (elapsed_today / block_secs) * block_secs))
block_end=$((current_block_start + block_secs))
reset_secs=$((block_end - now_epoch))
reset_hrs=$((reset_secs / 3600))
reset_mins=$(( (reset_secs % 3600) / 60 ))
reset_fmt="${reset_hrs}h${reset_mins}m"

# ── Build output ──
line=""
# Vim mode
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    NORMAL)  line+="${green}${vim_mode}${reset}" ;;
    INSERT)  line+="${blue}${vim_mode}${reset}" ;;
    VISUAL)  line+="${lavender}${vim_mode}${reset}" ;;
    *)       line+="${text}${vim_mode}${reset}" ;;
  esac
  line+="${dim} │ ${reset}"
fi
# Git branch + worktree + status counts
if [ -n "$branch" ]; then
  line+="${green} ${branch}${worktree}${reset}"
  git_counts=""
  [ "$staged" -gt 0 ] && git_counts+="${green}+${staged}${reset}"
  [ "$modified" -gt 0 ] && git_counts+="${peach}~${modified}${reset}"
  [ "$untracked" -gt 0 ] && git_counts+="${dim}?${untracked}${reset}"
  [ -n "$git_counts" ] && line+=" ${git_counts}"
  line+="${dim} │ ${reset}"
fi
# Directory
line+="${peach} ${dir_short}${reset}"
line+="${dim} │ ${reset}"
# Language/runtime
if [ -n "$lang" ]; then
  line+="${teal}${lang}${reset}"
  line+="${dim} │ ${reset}"
fi
# Lines changed (net indicator)
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
  line+="${green}+${lines_added}${reset} ${red}-${lines_removed}${reset} ${net_indicator}"
  line+="${dim} │ ${reset}"
fi
# Context (with early warning)
line+="${bar_color}${bar} ${context_pct}%${ctx_label}${reset}"
line+="${dim} │ ${reset}"
# Plan usage (compact)
line+="${plan_color}${plan_msgs}/${PLAN_MSG_LIMIT}${reset} ${dim}(${reset}${lavender}${reset_fmt}${reset}${dim})${reset}"
line+="${dim} │ ${reset}"
# Model (glyph)
line+="${blue}${model_glyph}${reset}"
line+="${dim} │ ${reset}"
# Duration
line+="${text} ${duration_fmt}${reset}"

echo -e "$line"
printf '\xe2\x80\x8b\n'
