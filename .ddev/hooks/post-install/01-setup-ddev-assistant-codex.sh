#!/bin/bash
#ddev-nodisplay
#ddev-description: Fix ownership of Codex configuration directory

set -e

echo "Fixing ownership of Codex configuration directory..."

if [ -d "$HOME/.codex" ]; then
    sudo chown -R $(id -u):$(id -g) "$HOME/.codex" 2>/dev/null || true
    echo "✓ Codex config directory ownership fixed"
fi
