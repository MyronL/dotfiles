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

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Homebrew (if not installed)"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing Homebrew packages"
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> Setting macOS defaults"
source "$DOTFILES_DIR/macos/defaults.sh"

echo "==> Installing TPM (Tmux Plugin Manager)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "    TPM already installed"
fi

echo "==> Setting up mise and installing Node.js"
eval "$(mise activate bash)"
if ! mise ls --installed node 2>/dev/null | grep -q lts; then
    mise use --global node@lts
else
    echo "    Node.js LTS already installed"
fi

echo "==> Installing/updating Claude Code"
npm install -g @anthropic-ai/claude-code@latest

echo "==> Stowing dotfiles"
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

for dir in */; do
    dir="${dir%/}"
    [[ "$dir" == .* ]] && continue
    echo "    Stowing $dir"
    resolve_conflicts "$dir"
done

echo "==> Installing tmux plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

if [ -n "${TMUX:-}" ]; then
    echo "==> Reloading tmux config"
    tmux source-file ~/.tmux.conf
fi

echo "==> Restarting AeroSpace"
if pgrep -x AeroSpace >/dev/null; then
    pkill AeroSpace && sleep 1
fi
open -a AeroSpace

echo "==> Building bat theme cache"
bat cache --build

echo "==> Installing SbarLua"
SBARLUA_DIR="$HOME/.local/share/sketchybar_lua"
if [ ! -f "$SBARLUA_DIR/sketchybar.so" ]; then
    SBARLUA_TMP="$(mktemp -d)"
    git clone https://github.com/FelixKratz/SbarLua.git "$SBARLUA_TMP"
    (cd "$SBARLUA_TMP" && make install)
    rm -rf "$SBARLUA_TMP"
else
    echo "    SbarLua already installed"
fi

echo "==> Installing wifi-unredactor"
WIFI_UNREDACTOR_APP="$HOME/Applications/wifi-unredactor.app"
if [ ! -d "$WIFI_UNREDACTOR_APP" ]; then
    WIFI_TMP="$(mktemp -d)"
    git clone https://github.com/noperator/wifi-unredactor.git "$WIFI_TMP"
    (cd "$WIFI_TMP" && ./build-and-install.sh)
    rm -rf "$WIFI_TMP"
    echo "    NOTE: Open wifi-unredactor once to grant Location Services permission"
else
    echo "    wifi-unredactor already installed"
fi

echo "==> Setting up sketchybar"
chmod +x ~/.config/sketchybar/sketchybarrc
brew services start sketchybar

echo "==> Configuring git hooks"
git -C "$DOTFILES_DIR" config core.hooksPath .githooks

echo "==> Clearing Dock"
source "$DOTFILES_DIR/macos/dock.sh"

echo ""
echo "Done! Next steps:"
echo "  1. Open Neovim — plugins will install automatically via lazy.nvim"

echo "==> Restarting shell to apply changes..."
if [ -z "${TMUX:-}" ]; then
    exec zsh
else
    echo "    Inside tmux — run 'source ~/.zshrc' or open a new pane to apply changes."
fi
