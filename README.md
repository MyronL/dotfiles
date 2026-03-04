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
| `git/` | [Git](https://git-scm.com/) | Global git configuration and ignore rules |
| `lazygit/` | [LazyGit](https://github.com/jesseduffield/lazygit) | Git TUI with delta pager |
| `nvim/` | [Neovim](https://neovim.io/) | LazyVim-based config with VSCode-Neovim support |
| `starship/` | [Starship](https://starship.rs/) | Cross-shell prompt |
| `tmux/` | [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| `wezterm/` | [WezTerm](https://wezfurlong.org/wezterm/) | GPU-accelerated terminal emulator |
| `zsh/` | [Zsh](https://www.zsh.org/) | Shell configuration |

## Highlights

### Theme

- **TokyoNight Night** across bat, delta, ghostty, wezterm, and neovim
- **Catppuccin Mocha** for starship and tmux
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

Zsh with `starship` prompt, `zoxide` (aliased to `cd`), `eza` (aliased to `ls`), `zsh-autosuggestions`, and `zsh-syntax-highlighting`. NVM for Node version management.

### Terminal

Both Ghostty and WezTerm configured with hidden title bars and matching fonts/themes. Ghostty includes a custom GLSL cursor smear shader.

### Git

`delta` as the pager with the TokyoNight theme, `nvim` as the editor, and `zdiff3` conflict style.

### Claude Code

Custom statusline with Catppuccin Mocha colors showing git branch (with worktree and status counts), directory, language/runtime detection, lines changed with net indicator, context window usage with early degradation warnings, Max5 plan usage tracking (messages used/remaining with 5-hour window reset countdown), model tier glyph, vim mode, and session duration. Plan usage is tracked by scanning local JSONL history files with a 30-second cache.

### tmux

`C-s` prefix, vim-style pane navigation, Catppuccin theme, and session persistence via `tmux-resurrect` + `tmux-continuum`.

## Installation

```sh
# Clone the repo
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# Run the install script (installs everything from scratch)
./install.sh
```

The install script will:

1. Check for **Xcode Command Line Tools** and prompt installation if missing
2. Install [Homebrew](https://brew.sh/) if not present
3. Install all CLI tools (`bat`, `eza`, `fd`, `fzf`, `gh`, `git`, `git-delta`, `lazygit`, `neovim`, `nvm`, `ripgrep`, `starship`, `stow`, `tmux`, `zoxide`, `zsh-autosuggestions`, `zsh-syntax-highlighting`)
4. Install GUI apps (`aerospace`, `ghostty`, `wezterm`) and **MesloLGS Nerd Font** — skips any already installed
5. Install [`borders`](https://github.com/FelixKratz/JankyBorders) for AeroSpace window borders
6. Install [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)
7. Install Node.js LTS via nvm
8. Install [Claude Code](https://docs.anthropic.com/en/docs/claude-code) globally via npm
9. Stow all dotfiles into `$HOME` (prompts to resolve conflicts with existing files)
10. Install tmux plugins via TPM
11. Reload tmux config if running inside a tmux session
12. Build the bat theme cache

After running, open Neovim to auto-install plugins via lazy.nvim.

### Manual stowing

Each directory is also a standalone stow package if you prefer to install selectively:

```sh
stow zsh
stow nvim
stow git
```
