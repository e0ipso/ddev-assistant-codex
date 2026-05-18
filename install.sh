#!/bin/bash
set -e

echo "Installing ddev-assistant-codex add-on..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install CLI tool
echo "Step 1: Installing Codex CLI..."
bash "$SCRIPT_DIR/src/install-cli.sh"

# Initialize AI Task Manager
echo "Step 2: Initializing AI Task Manager..."
bash "$SCRIPT_DIR/src/setup-ai-task-manager.sh"

# Configure MCP servers
echo "Step 3: Configuring MCP servers..."
bash "$SCRIPT_DIR/src/setup-mcp-servers.sh"

echo "✓ ddev-assistant-codex add-on installation complete!"
echo ""
echo "Verify installation with:"
echo "  ddev exec codex --version"
echo "  ddev exec ls -la .ai/task-manager/"
echo "  ddev exec codex mcp list"
