---
name: project-discoverer
description: Runs on first project open when .make/workspace.json does not exist. Detects available MCPs, connects to Make.com, lists all scenarios, and writes workspace.json. Shows setup instructions if Make MCP is missing.
---

# Skill: project-discoverer

Runs on first project open when `.make/workspace.json` does not exist.
Maps the Make.com workspace and available MCPs.

## Trigger Condition

Check for `.make/workspace.json`. If missing, run this skill before any other action.

## Steps

### 1. Detect Available MCPs

Check which MCPs are loaded in the current Claude session:
- `make` → required. If missing, stop and show setup instructions (see below).
- `telnyx` → note as available/unavailable. Set `alerts_enabled` accordingly.
- `supabase` → note availability. Surface to user if available.
- `n8n` → note availability.
- `github` → note availability.

### 2. Connect to Make.com

Using Make.com MCP:
- Verify API key is valid
- Fetch team/organization info
- Get plan tier and monthly operation limit
- Get current month operation usage

### 3. List All Scenarios

Fetch all scenarios in the workspace:
- Name, ID, status (active/inactive), last run date, module count
- Bundle into workspace map

### 4. Write workspace.json

Write to `.make/workspace.json`:
```json
{
  "workspace_id": "{make_team_id}",
  "name": "{team_name}",
  "region": "{region}",
  "plan_tier": "{core|pro|teams|enterprise}",
  "monthly_operation_limit": 10000,
  "operations_used_this_month": 2341,
  "scenarios": [
    {
      "id": "123",
      "name": "Lead Intake",
      "status": "active",
      "module_count": 8,
      "last_run_at": "2026-06-09T14:30:00Z"
    }
  ],
  "available_mcps": ["make", "telnyx"],
  "alerts_enabled": true,
  "discovered_at": "{timestamp}",
  "last_refreshed_at": "{timestamp}"
}
```

### 5. Present Discovery Summary

Show the user:
```
Make.com Workspace Connected
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Workspace: {name}
Plan: {tier} ({limit} operations/month)
Usage this month: {used} / {limit} ({percent}%)

Scenarios found: {count}
  Active: {n}
  Inactive: {n}

Available integrations:
  Make.com MCP: Connected
  Telegram alerts: {Connected / Not configured — see setup below}
  Supabase: {Connected / Not connected}
  n8n fallback: {Connected / Not connected}

{If any MCPs are missing, show setup instructions}
```

### 6. Recommend Missing MCPs (if any)

If `telnyx` MCP is missing:
```
Telegram alerts are not configured. To enable failure notifications:
1. Add your Telnyx API key: TELNYX_API_KEY=your-key
2. Set your Telegram chat ID: TELEGRAM_CHAT_ID=your-chat-id
3. Restart Claude Code

Would you like to set this up now?
```

## Make.com MCP Missing — Setup Instructions

If `make` MCP is not available, show this and stop:

```
The Make.com MCP is required but not connected.

To set it up:
1. Add your Make.com API key to your environment:
   MAKE_API_KEY=your-api-key
   MAKE_TEAM_ID=your-team-id

2. Add the Make.com MCP to your Claude Code configuration.
   Documentation: https://www.make.com/en/api-documentation

3. Restart Claude Code and reopen this project.

Your API key is available at:
https://www.make.com/en/help/account/your-api-key
```

## Refresh

Call this skill again (skip step 5) to refresh `workspace.json` on demand.
Agents should refresh workspace.json when it is more than 24 hours old.
