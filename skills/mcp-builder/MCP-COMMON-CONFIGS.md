# mcp-builder — Common MCP Configuration Snippets

Reference file for `skills/mcp-builder/MCP-BUILD-STEPS.md`.

## Make.com MCP

```json
{
  "mcpServers": {
    "make": {
      "command": "npx",
      "args": ["-y", "@makehq/mcp-server"],
      "env": {
        "MAKE_API_KEY": "${MAKE_API_KEY}",
        "MAKE_TEAM_ID": "${MAKE_TEAM_ID}"
      }
    }
  }
}
```

## Telnyx MCP

```json
{
  "mcpServers": {
    "telnyx": {
      "command": "npx",
      "args": ["-y", "@telnyx/mcp-server"],
      "env": {
        "TELNYX_API_KEY": "${TELNYX_API_KEY}"
      }
    }
  }
}
```

## Supabase MCP

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "${SUPABASE_URL}",
        "SUPABASE_KEY": "${SUPABASE_KEY}"
      }
    }
  }
}
```
