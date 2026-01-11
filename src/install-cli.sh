#!/bin/bash
set -e

# Check if Codex is already installed
if command -v claude &> /dev/null; then
    echo "Codex is already installed: $(claude --version)"
    exit 0
fi

# Install Codex CLI globally
echo "Installing @openai/codex..."
npm install -g @openai/codex

# Verify installation
if command -v claude &> /dev/null; then
    echo "✓ Codex installed successfully: $(claude --version)"
else
    echo "✗ Failed to install Codex CLI"
    exit 1
fi
