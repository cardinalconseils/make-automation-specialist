---
description: Show a live workspace status dashboard — active scenarios, operations usage, recent alerts, pending issues, and changelog summary. Read-only.
---

# /status — Workspace Status Dashboard

Read-only. No approval needed. All deterministic tool calls.

## Steps

1. Fetch all workspace state:
   - `mcp__claude_ai_Make__users_me` — current user
   - `mcp__claude_ai_Make__teams_list` — active team
   - `mcp__claude_ai_Make__scenarios_list` — all scenarios, count active vs inactive
   - `mcp__claude_ai_Make__executions_list` — recent runs across scenarios (last 24h)
   - `mcp__claude_ai_Make__hooks_list` — webhook count and status
   - `mcp__claude_ai_Make__connections_list` — connection count

2. Read local state:
   - `.make/logs/tool-audit.log` — recent tool activity
   - `.make/audits/` — last audit report date
   - `.make/plans/` — any pending (unapproved) plans
   - `.make/logs/approvals.md` — recent approvals

3. Display dashboard:

```
MAKE.COM WORKSPACE STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Team:     {team name}
User:     {name}
Zone:     {zone}

SCENARIOS
  Active:   {n}
  Inactive: {n}
  Errors (last 24h): {n}

OPERATIONS (this month)
  Used:  {n}
  Limit: {n}
  [{bar graph}] {%}%

CONNECTIONS
  Connected services: {n}  (list top 5)
  ⚠️  Broken connections: {n if any}

WEBHOOKS
  Active: {n}

RECENT ACTIVITY (last 24h)
  {list of scenario runs with status: ✅ success / ❌ failed}

PENDING PLANS
  {list any .make/plans/ files with status: pending-approval}

LAST AUDIT
  {date} — {critical: n, warnings: n}
  {if > 7 days ago: recommend running /audit}

ALERTS (last 7 days)
  {list from tool-audit.log or "No alerts"}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quick actions:
  /make     Build a new automation
  /audit    Audit all scenarios
  /plan     Draft a plan without building
```
