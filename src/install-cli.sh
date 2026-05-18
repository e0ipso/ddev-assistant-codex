#!/bin/bash
set -e

# Check if Codex is already installed
if command -v codex &> /dev/null; then
    echo "Codex is already installed: $(codex --version)"
    exit 0
fi

# Install Codex CLI globally
echo "Installing @openai/codex..."
npm install -g @openai/codex

# Verify installation
if command -v codex &> /dev/null; then
    echo "✓ Codex installed successfully: $(codex --version)"
else
    echo "✗ Failed to install Codex CLI"
    exit 1
fi
