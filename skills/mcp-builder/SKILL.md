---
name: mcp-builder
description: Scaffolds new MCP servers for APIs without native Make.com modules, and manages existing MCP connections in Claude Code. Two modes — scaffold (generate server code) and manage (check/configure existing MCPs). No Make.com MCP calls — file writes and Bash only.
---

# Skill: mcp-builder

Handles the full MCP server lifecycle for the Make.com automation project:
- **Scaffold mode:** Generate a minimal MCP server for a service with no native Make.com module
- **Manage mode:** Check connectivity, surface setup instructions for missing MCPs in Claude Code

This skill operates at the Claude Code level — it works with `.claude/` config and MCP server code,
NOT with Make.com's module system.

## Deterministic Classification — No Make.com MCP Calls

This skill makes ZERO `mcp__claude_ai_Make__*` calls.

Permitted operations:
- Bash (connectivity checks, npm/node version checks)
- Read / Write (scaffold server code, check `.claude/` config)
- File writes to `.make/mcp-servers/{service-name}/`

## Two Modes

### Mode 1 — Manage (Check Existing MCPs)

**When called:** Bootstrap gap analysis, on-project-open

Steps:
1. Check `.claude/settings.json` or `~/.claude/settings.json` for `mcpServers` config
2. For each configured MCP server: verify config entry, check env var, test connectivity

Output:
```
MCP SERVER STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ make        Connected (MAKE_API_KEY set)
✅ telnyx      Connected (TELNYX_API_KEY set)
⚠️  supabase   Configured but SUPABASE_KEY not set
❌ n8n         Not configured — see setup instructions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

For missing env vars, show:
```
To enable {mcp-name}: add {ENV_VAR_NAME}=your_key to your .env file,
then restart Claude Code.
```

For unconfigured MCPs, provide config snippet from `skills/mcp-builder/MCP-BUILD-STEPS.md`.

### Mode 2 — Scaffold (Generate MCP Server)

**When called:** Bootstrap identifies a service with no native Make.com module and no existing MCP

Decision gate first:
```
{service} doesn't have a native Make.com module.

Two options:
[1] Build a custom MCP server for {service} — I'll generate the code
    (adds connectivity directly to Claude Code; takes ~10 min to set up)
[2] Use Make.com's HTTP module to call {service}'s API directly
    (faster setup; no new server needed; less Make.com-native)

Which approach would you prefer?
```

If user chooses scaffold, proceed with full build steps: see `skills/mcp-builder/MCP-BUILD-STEPS.md`

## Output Contract

Returns to calling agent:
```json
{
  "mode": "manage|scaffold",
  "mcp_status": {
    "make": "connected",
    "telnyx": "connected",
    "supabase": "missing-env",
    "n8n": "not-configured"
  },
  "scaffolded": {
    "service": "{name}",
    "path": ".make/mcp-servers/{slug}/",
    "tools_generated": 4,
    "setup_required": true
  }
}
```
