# Scenario Orchestrator — Phase 1: Bootstrap

For Phase 0 (Kickstart), see `scenario-orchestrator-phases.md`.

## Phase 1 — BOOTSTRAP: Map the Workspace

Goal: understand what already exists before designing anything new.

Announce: "Now I'm mapping your Make.com workspace to see what's already there..."

Run ALL of these (deterministic — no approval needed):
1. `mcp__claude_ai_Make__users_me` — confirm auth + identity
2. `mcp__claude_ai_Make__teams_list` — get active team ID
3. `mcp__claude_ai_Make__scenarios_list` — inventory existing automations
4. `mcp__claude_ai_Make__connections_list` — authenticated services
5. `mcp__claude_ai_Make__hooks_list` — existing webhooks
6. `mcp__claude_ai_Make__data-structures_list` — existing schemas
7. `mcp__claude_ai_Make__data-stores_list` — existing data stores

Build workspace map and save to `.make/workspace.json`.

Surface findings to user:
```
WORKSPACE MAP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Existing scenarios:   {n} (I'll avoid duplicating these)
Connected services:   {list of service names}
Available webhooks:   {n}
Reusable schemas:     {n}

✅ Ready to connect: {services already authenticated}
⚠️  Needs setup before building: {services NOT yet connected}

{If any needed connections are missing:}
Before we build, you'll need to connect these services in Make.com:
• {service} — here's how: {plain-language instructions or doc link}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If missing connections are blocking: guide setup before continuing.
Do not proceed to design until the user confirms or acknowledges they'll set up later.

### Phase 1b — Tech Stack Gap Analysis

After workspace map, compare `.make/context/stack.md` against `workspace.json`.
If `stack.md` does not exist (kickstart was skipped): skip gap analysis.

| Gap Type | Skill to Call |
|----------|-------------|
| Required MCP not configured | `mcp-builder` (manage mode) |
| Required service not connected | `connector-builder` (setup-guide mode) |
| Data store needed but not present | `database-builder` (scaffold mode) |
| Service with no native module | `mcp-builder` (scaffold mode — offer choice) |

Surface results:
```
TECH STACK GAP ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Ready:       {n} services connected, {n} MCPs active
⚠️  Needs setup: {n} connections missing
❌ Blocking:    {list of services needed before we can build}

{For each blocker: plain-language setup instruction}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Write requirements checklist to `.make/context/requirements.md`.
Update `current-session.json` → `workspace_mapped: true`.
