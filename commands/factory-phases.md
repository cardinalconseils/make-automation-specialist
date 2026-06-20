# /factory — Phase Execution Detail

Reference file for `commands/factory.md`.

## Step 0 — Load or Create Factory Session

Check `.make/factory/current-session.json`:

```javascript
// If file exists and status !== "complete":
RESTORE → Show progress → Ask: "Continue where we left off, or start fresh?"

// If file doesn't exist or status === "complete":
CREATE → { session_id: "YYYY-MM-DD-HHmm", status: "kickstart", automations: [] }
```

Save: `.make/factory/current-session.json`
Also save timestamped copy: `.make/factory/{session_id}-session.json`

## Step 1 — KICKSTART Phase

Use the `kickstart-intake` skill to conduct the automation discovery interview.
If the user provided an argument to `/factory`, use it as the first automation seed.

Opening:
```
Make.com Automation Factory — starting up.
What's the first thing you want to automate?
```

Keep collecting until user signals done. Reflect each back and ask for more.
Show final portfolio and ask for confirmation before proceeding.

## Step 2 — BOOTSTRAP Phase

Announce: "Perfect — I have your {n} automations. Now I'll map your workspace..."

Deterministic reads (no approval needed):
1. `mcp__claude_ai_Make__users_me`
2. `mcp__claude_ai_Make__teams_list`
3. `mcp__claude_ai_Make__scenarios_list`
4. `mcp__claude_ai_Make__connections_list`
5. `mcp__claude_ai_Make__hooks_list`
6. `mcp__claude_ai_Make__data-structures_list`
7. `mcp__claude_ai_Make__data-stores_list`

Save to `.make/workspace.json`. Guide setup for any blocking missing connections.

## Step 3 — SYSTEM DESIGN Phase

See `commands/factory-sprint.md` for design loop and approval gate format.

## Step 4 — SPRINT Phase and Step 5 — Factory Report

See `commands/factory-sprint.md`.

## Deterministic / Non-Deterministic Reference

### Deterministic (safe in any factory phase)

All `list`, `get`, `interface`, `extract_*`, `validate_*`, `apps_recommend`,
`app_documentation_get`, `app-modules_list`, `app-module_get`, `users_me`,
`teams_list`, `enums_*`, `credential-requests_list`, `credential-requests_get`.

### Level 1 — Non-deterministic (Sprint phase only, gated)

`scenarios_create`, `scenarios_update`, `scenarios_activate`,
`scenarios_deactivate`, `hooks_create`, `hooks_update`.

### Level 2 — Non-deterministic (explicit user request only)

`scenarios_run`, `rpc_execute`.

### Level 3 — PROHIBITED in /factory

All `*_delete` operations. Redirect to `/audit` or `/fix`.
