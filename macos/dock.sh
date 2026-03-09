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
killall Dock

echo "    Dock cleared"
