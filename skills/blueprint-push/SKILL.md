---
name: blueprint-push
description: "Executes the full validated push cycle for a local blueprint: review → plan check → API push → validate isinvalid:false → log. The only sanctioned path for writing blueprint changes to Make."
allowed-tools: Bash, Read, Write, mcp__claude_ai_Make__validate_blueprint_schema, mcp__claude_ai_Make__connections_list
---

# Blueprint Push Skill

## Purpose
Execute the complete push cycle with no skippable steps. Each gate must pass before the next begins. This is the only path for applying local blueprint changes to Make.com.

## Protocol

### Step 1 — Confirm source file
Identify:
- Local blueprint file to push (default: `.make/scenarios/{scenarioId}.json`)
- Scenario ID and region
- This file must have been fetched this session OR explicitly confirmed as current

Never push a file that wasn't fetched this session without explicit user confirmation.

### Step 2 — Blueprint review (mandatory)
Run the `blueprint-review` skill on the file.

| Review result | Action |
|---------------|--------|
| PASS | Proceed to Step 3 |
| WARNINGS only | Surface warnings, ask user to confirm before proceeding |
| ISSUES | STOP. Fix issues, re-review. Do not push until PASS or confirmed WARNINGS |

### Step 3 — Plan check (mandatory)
Confirm a plan file exists in `.make/plans/` for this change set.

If none exists: run `plan-builder` skill first. Do not proceed without a plan.

### Step 4 — Push via API
```bash
curl -s -X PUT \
  "https://{region}.make.com/api/v2/scenarios/{scenarioId}" \
  -H "Authorization: Token ${MAKE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @.make/scenarios/{scenarioId}.json
```

Capture full response. Do not discard it.

### Step 5 — Validate response (hard gate)

Parse `isinvalid` from the response immediately:

| Response | Action |
|----------|--------|
| `isinvalid: false` | ✅ Proceed to Step 6 |
| `isinvalid: true` | ❌ STOP. Run `failure-diagnostician` skill on the response. Fix. Re-push from Step 1. |
| No `isinvalid` key | ⚠️ Show raw response. Ask user how to proceed. Do not log as success. |

**Do not continue to Step 6 if `isinvalid` is anything other than `false`.**

### Step 6 — Create log entry
Write `.make/logs/YYYY-MM-DD-{scenarioId}-{description}.md`:

Required fields:
- Date and scenario ID
- Push status: `isinvalid: false`
- `lastEdit` timestamp from response
- What changed: each module modified, each field, old → new value
- What did NOT change: explicit scope confirmation

### Step 7 — Report
```
✅ Push complete
Scenario: {name} ({id})
Status: isinvalid: false
lastEdit: {timestamp}
Log: .make/logs/{filename}.md
→ Scenario is live. Monitor the next execution.
```

## Rules
- Never skip the blueprint review (Step 2)
- Never skip the plan check (Step 3)
- Never continue after `isinvalid: true` — diagnose and fix before any retry
- One logical change set per push — never batch unrelated changes
- Always create the log entry (Step 6), including for small changes
- MAKE_API_KEY must come from environment — never hardcode it
