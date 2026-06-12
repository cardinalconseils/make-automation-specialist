# Hook: on-project-open

**Event:** project.open
**Trigger:** Fires when Claude Code opens this project (new session)

## Purpose

Ensure the workspace is discovered and ready before the user asks their first question.

## Execution

### Check 1 — Is this first open?

Read `.make/workspace.json`.
- Not found → run full project-discoverer skill
- Found → check `last_refreshed_at`
  - More than 24 hours ago → run refresh (skip presentation, just update file)
  - Recent → skip discovery, proceed to greeting

### Check 2 — Are required MCPs available?

Verify `make` MCP is accessible.
- Not accessible → show setup instructions (from project-discoverer skill), stop.
- Accessible → continue.

### Check 3 — Pending Alerts

Check `.make/logs/missed-alerts.md`.
- If file exists and has content → surface to user: "There were {n} alerts I couldn't
  send via Telegram while you were away. Here's a summary: [content]"
- If file empty or missing → skip.

### Check 4 — Pending Audit Warnings

Read workspace.json for `pending_warnings_count`.
- If > 0 → mention in greeting: "{n} audit warnings are awaiting your review. Type /audit to see them."
- If 0 → skip.

## Session Opening Greeting

After all checks, display:
```
Make.com Automation Specialist — Ready

Workspace: {name}
Plan: {tier} | Operations: {used}/{limit} this month ({percent}%)
Active scenarios: {count}

{If warnings pending: "Audit warnings: {n} pending — type /audit to review"}
{If alerts missed: "Missed alerts: {n} — review above"}

What would you like to do?
Type /make to build a new automation, /audit to review your scenarios,
or just tell me what you need.
```

## Silent Mode

If workspace discovery was already fresh (< 24 hours old) and no pending items,
just display the brief greeting. No verbose output unless something needs attention.
