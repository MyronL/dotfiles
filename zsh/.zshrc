# # Start the tmux session if not already in the tmux session
# if [[ ! -n $TMUX  ]]; then
#   # Get the session IDs
#   session_ids="$(tmux list-sessions)"
#
#   # Create new session if no sessions exist
#   if [[ -z "$session_ids" ]]; then
#     tmux new-session
#   fi
#
#   # Select from following choices
#   #   - Attach existing session
#   #   - Create new session
#   #   - Start without tmux
#   create_new_session="Create new session"
#   start_without_tmux="Start without tmux"
#   choices="$session_ids\n${create_new_session}:\n${start_without_tmux}:"
#   choice="$(echo $choices | fzf | cut -d: -f1)"
#
#   if expr "$choice" : "[0-9]*$" >&/dev/null; then
#     # Attach existing session
#     tmux attach-session -t "$choice"
#   elif [[ "$choice" = "${create_new_session}" ]]; then
#     # Create new session
#     tmux new-session
#   elif [[ "$choice" = "${start_without_tmux}" ]]; then
#     # Start without tmux
#     :
#   fi
# fi

EDITOR='nvim'

# Basic eza replacements for ls
alias ls='eza --icons=auto'

bindkey -e # for emacs

# source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi

eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(zoxide init zsh --cmd cd)"

# Add Homebrew bash to system path
export PATH="/opt/homebrew/bin:$PATH"



alias claude="/Users/myronloke/.claude/local/claude"
