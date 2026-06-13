# Hook: on-project-open

**Event:** project.open
**Trigger:** Fires when Claude Code opens this project (new session)

## Purpose

Ensure the workspace is discovered and ready before the user asks their first question.

## Execution

### Check 0 — Load Project Memory

Before workspace checks, load persistent memory using the `memory` skill:

```bash
# Most recent session snapshot
ls .make/memory/sessions/ 2>/dev/null | sort | tail -1
```

- If a session file exists: read it and extract the one-line summary
- If `.make/context/context.md` exists: note the project domain and goals
- Store this context — it informs the greeting and all responses this session

Memory summary will appear in the greeting if a prior session exists.

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

{If prior session memory exists:}
Last session: {date} — {one-line summary from snapshot}

{If context.md exists:}
Project: {domain from context.md}

Workspace: {name}
Plan: {tier} | Operations: {used}/{limit} this month ({percent}%)
Active scenarios: {count}

{If warnings pending: "Audit warnings: {n} pending — type /audit to review"}
{If alerts missed: "Missed alerts: {n} — review above"}

What would you like to do?
Type /kickstart to map a new project, /factory to build automations,
/make for a single automation, /audit to review scenarios,
or just tell me what you need.

For communications: /telnyx — SMS/voice/phone numbers | /sms — text messaging | /voice — phone calls & AI receptionist
```

## Silent Mode

If workspace discovery was already fresh (< 24 hours old) and no pending items,
just display the brief greeting. No verbose output unless something needs attention.
