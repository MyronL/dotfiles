#!/usr/bin/env bash
#
# macOS defaults
# Sets system preferences for a developer-focused environment.
# Run via install.sh or standalone: bash macos/defaults.sh

set -euo pipefail

echo "    Applying macOS defaults..."

# Close System Preferences to prevent it from overriding changes
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

###############################################################################
# Keyboard                                                                    #
###############################################################################

# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
# Short delay until repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Appearance                                                                  #
###############################################################################

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

###############################################################################
# Dock                                                                        #
###############################################################################

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true
# Icon size
defaults write com.apple.dock tilesize -int 41
# Enable magnification
defaults write com.apple.dock magnification -bool true
# Magnified icon size
defaults write com.apple.dock largesize -int 60
# Don't show recent applications
defaults write com.apple.dock show-recents -bool false
# Don't rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

###############################################################################
# Finder                                                                      #
###############################################################################

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Disable warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Default to list view in all windows
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Desktop Services                                                            #
###############################################################################

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Avoid creating .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
# Menu Bar                                                                    #
###############################################################################

# Auto-hide the menu bar (always)
# macOS Tahoe uses AutoHideMenuBarOption in com.apple.controlcenter
# Values: 0=Never, 1=In Full Screen Only, 2=On Desktop Only, 3=Always
defaults write com.apple.controlcenter AutoHideMenuBarOption -int 3

###############################################################################
# Restart affected applications                                               #
###############################################################################

for app in "Dock" "Finder" "SystemUIServer" "ControlCenter"; do
    killall "$app" &>/dev/null || true
done

echo "    macOS defaults applied. Some changes may require a logout/restart."
