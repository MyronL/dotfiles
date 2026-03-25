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

# ── Rate limits (native, Claude.ai subscribers) ──
rate_5h=$(echo "$data" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_7d=$(echo "$data" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_5h_resets=$(echo "$data" | jq -r '.rate_limits.five_hour.resets_at // empty')
rate_7d_resets=$(echo "$data" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Rate limit color (5h window)
if [ -n "$rate_5h" ]; then
  rate_5h_int=$(printf '%.0f' "$rate_5h")
  if [ "$rate_5h_int" -ge 80 ]; then
    rate_color="$red"
  elif [ "$rate_5h_int" -ge 60 ]; then
    rate_color="$peach"
  elif [ "$rate_5h_int" -ge 40 ]; then
    rate_color="$yellow"
  else
    rate_color="$green"
  fi

  # Rate limit bar (10 chars wide, same as context bar)
  rate_filled=$((rate_5h_int / 10))
  rate_empty=$((10 - rate_filled))
  rate_bar=""
  for ((i = 0; i < rate_filled; i++)); do rate_bar+="█"; done
  for ((i = 0; i < rate_empty; i++)); do rate_bar+="░"; done

  # Reset countdown from epoch seconds
  reset_fmt=""
  if [ -n "$rate_5h_resets" ]; then
    now_epoch=$(date +%s)
    reset_secs=$(printf '%.0f' "$rate_5h_resets")
    remaining=$((reset_secs - now_epoch))
    if [ "$remaining" -gt 0 ]; then
      reset_hrs=$((remaining / 3600))
      reset_mins=$(( (remaining % 3600) / 60 ))
      reset_fmt="${reset_hrs}h${reset_mins}m"
    fi
  fi
fi

# Rate limit color (7d window)
if [ -n "$rate_7d" ]; then
  rate_7d_int=$(printf '%.0f' "$rate_7d")
  if [ "$rate_7d_int" -ge 80 ]; then
    rate_7d_color="$red"
  elif [ "$rate_7d_int" -ge 60 ]; then
    rate_7d_color="$peach"
  elif [ "$rate_7d_int" -ge 40 ]; then
    rate_7d_color="$yellow"
  else
    rate_7d_color="$green"
  fi

  # 7d bar (10 chars wide)
  rate_7d_filled=$((rate_7d_int / 10))
  rate_7d_empty=$((10 - rate_7d_filled))
  rate_7d_bar=""
  for ((i = 0; i < rate_7d_filled; i++)); do rate_7d_bar+="█"; done
  for ((i = 0; i < rate_7d_empty; i++)); do rate_7d_bar+="░"; done

  # 7d reset countdown
  reset_7d_fmt=""
  if [ -n "$rate_7d_resets" ]; then
    now_epoch=$(date +%s)
    reset_7d_secs=$(printf '%.0f' "$rate_7d_resets")
    remaining_7d=$((reset_7d_secs - now_epoch))
    if [ "$remaining_7d" -gt 0 ]; then
      reset_7d_days=$((remaining_7d / 86400))
      reset_7d_hrs=$(( (remaining_7d % 86400) / 3600 ))
      reset_7d_fmt="${reset_7d_days}d${reset_7d_hrs}h"
    fi
  fi
fi

# ── Build output ──
line=""
# TODO: add vim mode back when Claude Code allows hiding the built-in "-- INSERT --" indicator
# if [ -n "$vim_mode" ]; then
#   case "$vim_mode" in
#     NORMAL)  line+="${green}${vim_mode}${reset}" ;;
#     INSERT)  line+="${blue}${vim_mode}${reset}" ;;
#     VISUAL)  line+="${lavender}${vim_mode}${reset}" ;;
#     *)       line+="${text}${vim_mode}${reset}" ;;
#   esac
#   line+="${dim} │ ${reset}"
# fi
# Directory
line+="${peach}${dir_short}${reset}"
line+="${dim} │ ${reset}"
# Git branch + worktree + status counts
if [ -n "$branch" ]; then
  line+="${green}${branch}${worktree}${reset}"
  git_counts=""
  [ "$staged" -gt 0 ] && git_counts+="${green}+${staged}${reset}"
  [ "$modified" -gt 0 ] && git_counts+="${peach}~${modified}${reset}"
  [ "$untracked" -gt 0 ] && git_counts+="${dim}?${untracked}${reset}"
  [ -n "$git_counts" ] && line+=" ${git_counts}"
  line+="${dim} │ ${reset}"
fi
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
line+="${bar_color}󰧑 ${bar} ${context_pct}%${ctx_label}${reset}"
line+="${dim} │ ${reset}"
# Rate limits (if available)
if [ -n "$rate_5h" ]; then
  line+="${rate_color}󰔛 ${rate_bar} ${rate_5h_int}%${reset}"
  [ -n "$reset_fmt" ] && line+=" ${dim}(${reset}${lavender}${reset_fmt}${reset}${dim})${reset}"
  line+="${dim} │ ${reset}"
fi
# 7-day rate limit (if available)
if [ -n "$rate_7d" ]; then
  line+="${rate_7d_color}󰃭 ${rate_7d_bar} ${rate_7d_int}%${reset}"
  [ -n "$reset_7d_fmt" ] && line+=" ${dim}(${reset}${lavender}${reset_7d_fmt}${reset}${dim})${reset}"
  line+="${dim} │ ${reset}"
fi
# Model (glyph)
line+="${blue}${model_glyph}${reset}"
line+="${dim} │ ${reset}"
# Duration
line+="${text}${duration_fmt}${reset}"

echo -e "$line"
printf '\xe2\x80\x8b\n'
