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

echo "==> Stowing dotfiles"
cd "$(dirname "$0")"
for dir in aerospace bat delta gh ghostty git lazygit nvim starship tmux wezterm zsh; do
    echo "    Stowing $dir"
    stow --adopt "$dir"
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
