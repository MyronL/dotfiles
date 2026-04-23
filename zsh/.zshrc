# Auto-attach to tmux: attach existing session or create new one
if [[ -z "$TMUX" ]] && command -v tmux &>/dev/null; then
  tmux attach-session 2>/dev/null || tmux new-session
fi

EDITOR='nvim'
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Basic eza replacements for ls
alias ls='eza --icons=auto'
alias reload='exec zsh'

# Vim mode (zsh-vi-mode)
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# FZF — use fd as backend, TokyoNight Night theme
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS=" \
  --height=40% --layout=reverse \
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 \
  --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff \
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
# Re-init keybinding-dependent plugins after zsh-vi-mode takes over
zvm_after_init() {
  source <(fzf --zsh)
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  eval "$(starship init zsh)"
  eval "$(navi widget zsh)"
}
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$HOME/.local/bin:$PATH"

# Rust / cargo — source the rustup-generated env if it exists,
# otherwise fall back to the rustup toolchain dir directly.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin" ] && \
  export PATH="$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"

# Enable Claude Code's flicker-free fullscreen rendering by default
export CLAUDE_CODE_NO_FLICKER=1

# Disable zoxide's doctor check — mise's chpwd_functions manipulation causes false positives
export _ZO_DOCTOR=0

eval "$(mise activate zsh)"

_mise_prompt_install() {
  local missing
  missing=$(mise ls --missing 2>/dev/null)
  if [[ -n "$missing" ]]; then
    echo "$missing"
    read -q "?Install missing mise tools? [y/N] " && { echo; mise install; } || echo
  fi
}
chpwd_functions+=(_mise_prompt_install)

# zoxide must be last — it wraps `cd` and breaks if anything re-defines it after
eval "$(zoxide init zsh --cmd cd)"
