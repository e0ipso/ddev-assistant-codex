# ddev-assistant-codex

DDEV addon for @openai/codex assistant with MCP server support.

## Installation

```bash
ddev add-ons install ddev-assistant-codex
```

## What This Addon Does

- Installs @openai/codex CLI
- Configures MCP servers (Puppeteer by default)
- Seeds host Codex config into a writable container runtime directory

## Quick Start

After installation, verify the setup:

```bash
ddev exec codex --version
ddev exec codex mcp list
```

## Configuration

### Codex Credentials And Runtime Config

The add-on mounts your host `~/.codex` directory into the web container as a
read-only seed at `~/.cred-seed/codex`. During container startup, missing files
from that seed are copied into the writable runtime config directory at
`~/.codex`, and `CODEX_CONFIG_DIR` points Codex there.

This lets Codex start from your host credentials and settings while still
allowing in-container token refreshes and config changes. Runtime files can
drift from the host after startup. The seed is copied again only for missing
files or fresh runtime state, so existing runtime changes are not overwritten.

### Custom MCP Servers

To add custom MCP servers, create `.ddev/mcp-config/codex.json`:

```json
{
  "mcp_servers": [
    {
      "name": "my-server",
      "enabled": true,
      "command": "npx -y @myorg/my-mcp-server",
      "environment": {
        "ENV_VAR": "value"
      }
    }
  ]
}
```

## Troubleshooting

### Codex CLI not found
```bash
ddev restart
ddev exec which codex
```

### MCP servers not configured
```bash
ddev exec codex mcp list
```

## Documentation

- [@openai/codex](https://code.codex.com/)
- [DDEV Addons](https://docs.ddev.com/en/stable/users/extend/creating-add-ons/)
