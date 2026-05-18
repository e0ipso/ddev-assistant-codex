#!/bin/bash
set -e

# Initialize AI Task Manager for Codex
echo "Setting up AI Task Manager for Codex..."

# Check if .ai/task-manager directory exists and has metadata
if [ -f ".ai/task-manager/.init-metadata.json" ]; then
    echo "✓ AI Task Manager already initialized"
    exit 0
fi

# Initialize AI Task Manager via npx
if npx @e0ipso/ai-task-manager init --assistant=codex; then
    echo "✓ AI Task Manager initialized for Codex"
else
    echo "⚠ Warning: AI Task Manager initialization had issues (may already be initialized)"
fi
