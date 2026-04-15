#!/usr/bin/env bash
#
# Clear the Dock completely using dockutil.
# AeroSpace handles app launching/switching, so the Dock is unnecessary.

set -euo pipefail

echo "    Clearing Dock..."

if ! command -v dockutil &>/dev/null; then
    echo "    dockutil not installed, skipping Dock cleanup"
    exit 0
fi

dockutil --remove all --no-restart

# Add Downloads folder back (fan view, sorted by most recent)
defaults write com.apple.dock persistent-others -array-add '<dict>
    <key>tile-data</key>
    <dict>
        <key>arrangement</key>
        <integer>2</integer>
        <key>displayas</key>
        <integer>0</integer>
        <key>file-data</key>
        <dict>
            <key>_CFURLString</key>
            <string>file:///Users/'"$USER"'/Downloads/</string>
            <key>_CFURLStringType</key>
            <integer>15</integer>
        </dict>
        <key>file-type</key>
        <integer>2</integer>
        <key>showas</key>
        <integer>1</integer>
    </dict>
    <key>tile-type</key>
    <string>directory-tile</string>
</dict>'

killall Dock

echo "    Dock configured"
