# Sprint Runner: Input, Opening, Error Handling, Controls

## Input Contract

Receives from orchestrator:
- `approved_automations` — ordered list from kickstart-intake (with designs attached)
- `workspace` — loaded `.make/workspace.json`
- `session_id` — for log file naming

## Opening Announcement

```
SPRINT STARTED — BUILDING {n} AUTOMATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
I'll build each automation one at a time.
I'll tell you what I'm doing before each step.
You can type "skip" to skip an automation or "stop" to pause the sprint.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling Protocol

### Tier 1 — Auto-Retry

On any Make.com MCP error:
1. Log the raw error to `.make/logs/`
2. Wait 30 seconds
3. Retry the failed call once
4. If retry succeeds: continue build, note the retry in the log
5. If retry fails: → Tier 2

### Tier 2 — Skip with Log

1. Write detailed error to `.make/logs/{timestamp}-error-{slug}.json`
2. Mark automation as `"failed"` in `current-session.json`
3. Surface to user in plain language (never show raw API errors):
   ```
   ⚠️  Couldn't build "{auto.title}" — {plain-language reason}.
   I've logged the details. Skipping to the next automation.
   Want me to try again, or move on?
   ```
4. If ≥2 consecutive failures: → Tier 3

### Tier 3 — Telegram Alert + Pause

1. Send Telegram alert via `mcp__telnyx__send_message`:
   ```
   Make.com Factory Alert
   {n} consecutive build failures in session {session_id}.
   Last failure: {auto.title} / Error: {plain-language summary}
   Action needed: check Make.com connections and retry.
   ```
2. Pause the sprint
3. Surface to user with full context and ask how to proceed

## User Control Signals During Sprint

| User says | Action |
|-----------|--------|
| "yes" / "continue" / "next" | Proceed to next automation |
| "skip" | Skip current, mark as skipped, move to next |
| "stop" | Pause sprint, save state, offer to resume later |
| "redo" / "try again" | Retry the most recent automation |
| "change X" | Allow in-sprint plan modification (re-validate before re-executing) |
