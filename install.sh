#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking for Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    echo "    Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "    Please wait for the installation to complete, then re-run this script."
    exit 1
else
    echo "    Xcode Command Line Tools already installed"
fi

echo "==> Installing Homebrew (if not installed)"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing Homebrew formulae"
brew install \
    bat \
    eza \
    fd \
    fzf \
    gh \
    git \
    git-delta \
    lazygit \
    neovim \
    nvm \
    ripgrep \
    starship \
    stow \
    tmux \
    zoxide \
    zsh-autosuggestions \
    zsh-syntax-highlighting

casks=(
    aerospace
    font-meslo-lg-nerd-font
    ghostty
    wezterm
)

echo "==> Installing Homebrew casks"
for cask in "${casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "    $cask already installed"
    else
        brew install --cask "$cask" || echo "    $cask skipped (may already exist outside Homebrew)"
    fi
done

echo "==> Installing borders (window border utility for AeroSpace)"
brew tap FelixKratz/formulae
brew install borders

echo "==> Installing TPM (Tmux Plugin Manager)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "    TPM already installed"
fi

echo "==> Setting up NVM and installing Node.js"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
nvm install --lts

echo "==> Installing/updating Claude Code"
npm install -g @anthropic-ai/claude-code@latest

echo "==> Stowing dotfiles"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

resolve_conflicts() {
    local pkg="$1"
    # Dry-run stow to detect conflicts (--no-folding ensures individual file
    # symlinks are created instead of directory-level symlinks, which avoids
    # conflicts with directories like ~/.claude/ that programs actively manage)
    local output
    output=$(stow -n --no-folding "$pkg" 2>&1) || true

    # Extract conflicting file paths from stow output
    local conflicts=()
    while IFS= read -r line; do
        # stow reports conflicts in different formats depending on version:
        #   Old: "* existing target is neither a link nor a directory: <path>"
        #   New: "* cannot stow ... over existing target <path> since ..."
        if [[ "$line" =~ existing\ target\ is.*:\ (.+) ]]; then
            conflicts+=("${BASH_REMATCH[1]}")
        elif [[ "$line" =~ existing\ target\ (.+)\ since\  ]]; then
            conflicts+=("${BASH_REMATCH[1]}")
        fi
    done <<< "$output"

    if [ ${#conflicts[@]} -eq 0 ]; then
        stow --no-folding "$pkg"
        return
    fi

    echo ""
    echo "    Conflicts found for '$pkg':"
    for file in "${conflicts[@]}"; do
        local target="$HOME/$file"
        local source="$DOTFILES_DIR/$pkg/$file"
        echo ""
        echo "    --- $file ---"
        if diff -q "$source" "$target" &>/dev/null; then
            echo "    Files are identical. Replacing with symlink."
            rm "$target"
        else
            # Show a short diff
            echo "    Diff (dotfiles vs existing):"
            diff --color=auto -u "$source" "$target" | head -30 || true
            echo ""
            echo "    What do you want to do?"
            echo "      [d] Use dotfiles version (override existing)"
            echo "      [e] Keep existing version (adopt into dotfiles)"
            echo "      [s] Skip this file"
            while true; do
                read -rp "    Choice [d/e/s]: " choice
                case "$choice" in
                    d|D)
                        rm "$target"
                        echo "    -> Will use dotfiles version"
                        break
                        ;;
                    e|E)
                        cp "$target" "$source"
                        rm "$target"
                        echo "    -> Adopted existing version into dotfiles"
                        break
                        ;;
                    s|S)
                        echo "    -> Skipped"
                        break
                        ;;
                    *)
                        echo "    Invalid choice. Enter d, e, or s."
                        ;;
                esac
            done
        fi
    done

    # Stow whatever is left (skipped files may still cause conflicts, so use --override)
    stow --no-folding "$pkg" 2>/dev/null || true
}

for dir in aerospace bat claude delta gh ghostty git lazygit nvim starship tmux wezterm zsh; do
    echo "    Stowing $dir"
    resolve_conflicts "$dir"
done

echo "==> Installing tmux plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

if [ -n "${TMUX:-}" ]; then
    echo "==> Reloading tmux config"
    tmux source-file ~/.tmux.conf
fi

echo "==> Building bat theme cache"
bat cache --build

echo ""
echo "Done! Next steps:"
echo "  1. Restart your terminal"
echo "  2. Open Neovim — plugins will install automatically via lazy.nvim"
