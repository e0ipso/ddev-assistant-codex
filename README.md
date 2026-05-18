# ddev-assistant-codex

DDEV addon for @openai/codex assistant with MCP server support.

## Installation

```bash
ddev add-ons install ddev-assistant-codex
```

## What This Addon Does

- Installs @openai/codex CLI
- Configures MCP servers (Puppeteer by default)
- Fixes configuration directory ownership

## Quick Start

After installation, verify the setup:

```bash
ddev exec codex --version
ddev exec codex mcp list
```

## Configuration

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
