# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). macOS-focused, terminal-centric development environment built around Neovim, modern CLI tools, and tiling window management.

## Tools

| Directory | Tool | Description |
|-----------|------|-------------|
| `aerospace/` | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | i3-inspired tiling window manager for macOS |
| `bat/` | [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting |
| `claude/` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Anthropic's CLI for Claude |
| `delta/` | [delta](https://github.com/dandavid/delta) | Git diff viewer with syntax highlighting |
| `gh/` | [GitHub CLI](https://cli.github.com/) | GitHub CLI aliases and settings |
| `ghostty/` | [Ghostty](https://ghostty.org/) | GPU-accelerated terminal emulator |
| `git/` | [Git](https://git-scm.com/) | Global git configuration, ignore rules, and difftastic |
| `glow/` | [Glow](https://github.com/charmbracelet/glow) | Markdown renderer with TokyoNight theme, paging, and line numbers |
| `lazygit/` | [LazyGit](https://github.com/jesseduffield/lazygit) | Git TUI with delta pager |
| `nvim/` | [Neovim](https://neovim.io/) | LazyVim-based config with VSCode-Neovim support |
| `ripgrep/` | [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive search with smart defaults |
| `sketchybar/` | [SketchyBar](https://github.com/FelixKratz/SketchyBar) | Custom macOS menu bar replacement |
| `ssh/` | [OpenSSH](https://www.openssh.com/) | SSH config with multiplexing and keychain integration |
| `starship/` | [Starship](https://starship.rs/) | Cross-shell prompt |
| `tmux/` | [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| `wezterm/` | [WezTerm](https://wezfurlong.org/wezterm/) | GPU-accelerated terminal emulator |
| `zsh/` | [Zsh](https://www.zsh.org/) | Shell configuration |

## Highlights

### Theme

- **TokyoNight Night** across bat, delta, glow, ghostty, wezterm, and neovim
- **Catppuccin Mocha** for starship, tmux, and sketchybar
- **MesloLGS Nerd Font Mono** as the terminal font

### Neovim

Built on [LazyVim](https://www.lazyvim.org/) with dual-mode support — detects VSCode-Neovim and loads a lightweight config accordingly. Language support for TypeScript, Vue, Svelte, Tailwind, Docker, .NET, and more. Uses `fzf-lua` for fuzzy finding, `mini.files` for file navigation, and `neotest` with Vitest/Jest adapters for testing.

### Window Management

AeroSpace with automatic workspace assignment, vim-style navigation (`alt-hjkl`), and 15px gaps.

| Workspace | App | Mnemonic |
|-----------|-----|----------|
| T | Ghostty | Terminal |
| W | Zen Browser | Web |
| 1 | Microsoft Teams | Teams |
| C | Google Chrome | Chrome |
| O | Microsoft Outlook | Outlook |
| P | Postman | Postman |
| M | Spotify | Music |
| S | Slack | Slack |

### Shell

Zsh with `starship` prompt, `zsh-vi-mode` (surround, text objects, visual mode, cursor shape), `zoxide` (aliased to `cd`), `eza` (aliased to `ls`), `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `fzf` with TokyoNight colors and `fd` backend. `mise` for language version management.

### Terminal

Both Ghostty and WezTerm configured with hidden title bars and matching fonts/themes. Ghostty includes a custom GLSL cursor smear shader.

### Git

`delta` as the pager with the TokyoNight theme, `difftastic` as the structural diff tool for `git diff`, `nvim` as the editor, and `zdiff3` conflict style.

### SSH

Connection multiplexing via `ControlMaster` (sockets in `~/.ssh/sockets/`), `UseKeychain` + `AddKeysToAgent` for macOS keychain integration, and `IdentitiesOnly yes` to avoid offering every key to every host. The tracked config includes `~/.ssh/config.local` for machine-local overrides — create it on a fresh machine to hold work/client host aliases and identities that shouldn't live in a public repo:

```sh
touch ~/.ssh/config.local && chmod 600 ~/.ssh/config.local
```

Example entry for a second GitHub identity:

```sshconfig
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
```

### Claude Code

Custom statusline with Catppuccin Mocha colors showing directory, git branch (with worktree and status counts), language/runtime detection, lines changed with net indicator, context window usage with early degradation warnings, native rate limit tracking (5-hour and 7-day usage percentage with reset countdown), model tier glyph, and session duration.

### SketchyBar

Lua-based macOS menu bar replacement with Catppuccin Mocha theme and [SbarLua](https://github.com/FelixKratz/SbarLua). Left side shows Apple menu, color-coded AeroSpace workspaces (with app icons), and focused app. Right side shows calendar, WiFi, volume (scroll-to-adjust), CPU, battery, notifications (Outlook/Teams/Slack badge aggregation), weather (via WeatherKit/Swift), DND status, meeting indicator, microphone toggle, and media player with playback controls. Click any widget for a detail popup (IP address, top processes, battery health, forecast details, etc.). Smooth `tanh` animations for workspace changes, track changes, and notification bounces.

### tmux

`C-s` prefix with Catppuccin Mocha theme and session persistence via `tmux-resurrect` + `tmux-continuum` (auto-restore on startup). Vim-style pane navigation (`h/j/k/l`) and resizing (`H/J/K/L`). Vi copy-mode with `v` to select and `y` to yank to system clipboard. Fzf-powered session switcher (`prefix + f`). Windows and panes start at index 1 with automatic renumbering. 50k line scrollback buffer. Focus events enabled for vim autoread. Status bar shows [gitmux](https://github.com/arl/gitmux) (branch, ahead/behind, working tree status), current directory, and session name. Auto-attach to tmux on shell startup via `.zshrc`.

## Installation

### Quick bootstrap (fresh machine)

```sh
git clone https://github.com/MyronL/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
```

### Standard install

```sh
git clone git@github.com:MyronL/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will:

1. Check for **Xcode Command Line Tools** and prompt installation if missing
2. Install [Homebrew](https://brew.sh/) if not present
3. Install all taps, formulae, and casks via `brew bundle` using the [`Brewfile`](Brewfile)
4. Apply [macOS defaults](macos/defaults.sh) (keyboard, Dock, Finder, screenshots)
5. Install [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)
6. Install Node.js LTS via mise
7. Install [Claude Code](https://docs.anthropic.com/en/docs/claude-code) globally via npm
8. Stow all dotfiles into `$HOME` (auto-detects packages, prompts to resolve conflicts)
9. Install tmux plugins via TPM
10. Reload tmux config if running inside a tmux session
11. Restart [AeroSpace](https://github.com/nikitabobko/AeroSpace)
12. Build the bat theme cache
13. Install [SbarLua](https://github.com/FelixKratz/SbarLua) and start [SketchyBar](https://github.com/FelixKratz/SketchyBar)
14. Install [wifi-unredactor](https://github.com/noperator/wifi-unredactor)
15. Configure git hooks and clear the Dock

After running, open Neovim to auto-install plugins via lazy.nvim.

### Manual stowing

Each directory is also a standalone stow package if you prefer to install selectively:

```sh
stow --no-folding zsh
stow --no-folding nvim
stow --no-folding git
```

## Future Additions

- [x] **FZF configuration** — Set `FZF_DEFAULT_COMMAND` (use fd), `FZF_DEFAULT_OPTS` (theme colors), and source key-bindings/completion (`Ctrl-R` history, `Ctrl-T` file picker, `Alt-C` cd)
- [ ] **Shell aliases & functions** — Directory navigation (`..`/`...`), safety aliases (`cp -i`, `mv -i`), quick git aliases in shell, utility functions (`mkcd`, `extract`)
- [x] **Shell history config** — `HISTSIZE`, `SAVEHIST`, dedup options (`SHARE_HISTORY`, `HIST_IGNORE_DUPS`, `HIST_IGNORE_SPACE`)
- [x] **macOS defaults script** — Automate system preferences (key repeat speed, Dock auto-hide, Finder hidden files, screenshot format, etc.)
- [x] **Global gitignore** — `~/.config/git/ignore` for `.DS_Store`, `*.swp`, `.env`, `node_modules/`, `.idea/`, `.vscode/`
- [x] **SSH config** — Host aliases, `ControlMaster` multiplexing, key settings
- [x] **Brewfile** — Replace inline `brew install` with a declarative `Brewfile` via `brew bundle`
- [ ] **direnv** — Per-directory environment variables (auto-loads `.envrc`)
- [x] **ripgrep config** — `~/.ripgreprc` with defaults like `--smart-case`, `--hidden`
- [x] **mise** — Multi-language version manager to replace nvm/pyenv/rbenv with a single tool
- [x] **Git extras** — Enable `rerere`, `pull.rebase`, `push.autoSetupRemote`, `init.defaultBranch`, commit signing
- [ ] **editorconfig** — `.editorconfig` for consistent indent/encoding across projects
