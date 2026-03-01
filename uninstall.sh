#!/bin/bash
# claude-sessions uninstaller
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"

echo "Removing claude-sessions..."
rm -f "$INSTALL_DIR/claude-sessions"
rm -f "$INSTALL_DIR/claude-sessions-preview"
rm -f "$HOME/.claude/.session-scan-cache.json"
rm -f "$HOME/.claude/.session-cache.json"

echo "Done. claude-sessions has been removed."
