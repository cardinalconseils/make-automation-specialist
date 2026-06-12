---
name: sprint-runner
description: Sequential scenario build executor. Iterates through an approved automation portfolio, builds each scenario in Make.com one at a time with narration and per-scenario confirmation, writes logs, and produces a factory report. Called by scenario-orchestrator during the Sprint phase.
---

# Skill: sprint-runner

Executes an approved automation portfolio sequentially. Called by scenario-orchestrator
after the user has approved the full batch design. This skill owns the Make.com write
operations — all prior phases are read-only.

## Deterministic Classification — This Skill Owns Writes

This skill is the ONLY place in the `/factory` pipeline where non-deterministic calls
are made. It runs ONLY during `status: "sprint"` in the factory session.

### Tools allowed in this skill

**Deterministic (call freely, no gate):**
```
mcp__claude_ai_Make__scenarios_get       ← verify before/after writes
mcp__claude_ai_Make__scenarios_list      ← duplicate check
mcp__claude_ai_Make__connections_list    ← prerequisite check
mcp__claude_ai_Make__hooks_get           ← verify webhook after create
```

**Non-deterministic Level 1 (pre-execute hook gates these):**
```
mcp__claude_ai_Make__scenarios_create    ← builds the scenario
mcp__claude_ai_Make__scenarios_activate  ← makes it live
mcp__claude_ai_Make__scenarios_update    ← applies fixes during sprint
mcp__claude_ai_Make__hooks_create        ← creates webhook trigger
```

**Non-deterministic Level 2 (HIGH RISK gate — never called automatically):**
```
mcp__claude_ai_Make__scenarios_run       ← only if user explicitly asks to test-run
```

**Non-deterministic Level 3 (DESTRUCTIVE — never called in sprint-runner):**
```
All *_delete tools — PROHIBITED in this skill entirely
```

### Phase enforcement

If `current-session.json` status is anything other than `"sprint"`, this skill
must refuse to make any non-deterministic calls and return control to the orchestrator.

---

## Input Contract

Receives from orchestrator:
- `approved_automations` — ordered list from kickstart-intake (with designs attached)
- `workspace` — loaded `.make/workspace.json`
- `session_id` — for log file naming

---

## Execution Protocol

### Opening Announcement

```
SPRINT STARTED — BUILDING {n} AUTOMATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
I'll build each automation one at a time.
I'll tell you what I'm doing before each step.
You can type "skip" to skip an automation or "stop" to pause the sprint.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Per-Automation Build Sequence

For each automation `auto` in the approved list:

#### Pre-Build Check

```
[{n} of {total}] Starting: {auto.title}
```

1. Check workspace map — does an identical/duplicate scenario already exist?
   - If yes: show duplicate warning → ask user to confirm or skip
2. Check all required connections exist in `workspace.connections`
   - If missing: surface warning and ask to confirm before proceeding

#### Blueprint Construction

Before any Make.com calls, construct the scenario blueprint JSON in memory using
the design from Phase 2. Blueprint must include:
- Module flow (trigger + all steps)
- Error handler routes
- Data mappings
- Scheduling (if applicable)
- Metadata: name, description, team ID

#### Narrated Build Steps

Narrate BEFORE every non-deterministic call:

**Step A — Create Scenario**
```
Creating the "{auto.title}" scenario in Make.com...
```
Call: `mcp__claude_ai_Make__scenarios_create`

On success: capture `scenario_id`.
On error: → Error Handling Protocol (see below).

**Step B — Create Webhook (if trigger type = webhook)**
```
Setting up the webhook trigger for "{auto.title}"...
```
Call: `mcp__claude_ai_Make__hooks_create`

Capture webhook URL. Save to `.make/scenarios/{scenario_id}.json`.

**Step C — Verify Before Activation**
```
Checking the scenario looks correct before going live...
```
Call: `mcp__claude_ai_Make__scenarios_get` → inspect returned config.

If validation fails: show what's wrong → offer to fix or skip.

**Step D — Activate**
```
Activating "{auto.title}" — this scenario will be live now...
```
Call: `mcp__claude_ai_Make__scenarios_activate`

**Step E — Final Verification**
Call: `mcp__claude_ai_Make__scenarios_get` → confirm `status === "active"`.

#### Post-Build Actions

1. Write execution log (execution-logger skill) → `.make/logs/{timestamp}-{slug}.json`
2. Write changelog entry → `.make/changelog/{scenario_id}.md`:
   ```
   ## {date} — Created
   Built via /factory session {session_id}.
   Trigger: {trigger}
   Steps: {n modules}
   ```
3. Update `current-session.json` → mark `auto.status = "built"`
4. Show per-scenario confirmation:

```
✅ [{n}/{total}] BUILT: {auto.title}
   Scenario ID: {scenario_id}
   Status: Active
   {If webhook: Webhook URL: {url}}
   
   How to test it:
   {plain-language test instruction based on trigger type}
   
   ─────────────────────────────────────────────────
   Next: [{n+1}/{total}] {next_auto.title}
   Ready to continue? (yes / skip / stop)
```

Wait for user response before proceeding to next automation.

---

### Error Handling Protocol

#### Tier 1 — Auto-Retry

On any Make.com MCP error:
1. Log the raw error to `.make/logs/`
2. Wait 30 seconds
3. Retry the failed call once
4. If retry succeeds: continue build, note the retry in the log
5. If retry fails: → Tier 2

#### Tier 2 — Skip with Log

1. Write detailed error to `.make/logs/{timestamp}-error-{slug}.json`
2. Mark automation as `"failed"` in `current-session.json`
3. Surface to user in plain language (never show raw API errors):
   ```
   ⚠️  Couldn't build "{auto.title}" — {plain-language reason}.
   I've logged the details. Skipping to the next automation.
   Want me to try again, or move on?
   ```
4. If ≥2 consecutive failures in a row → Tier 3

#### Tier 3 — Telegram Alert + Pause

1. Send Telegram alert via `mcp__telnyx__send_message`:
   ```
   Make.com Factory Alert
   {n} consecutive build failures in session {session_id}.
   Last failure: {auto.title}
   Error: {plain-language summary}
   Action needed: check Make.com connections and retry.
   ```
2. Pause the sprint
3. Surface to user with full context and ask how to proceed

---

### User Control Signals During Sprint

| User says | Action |
|-----------|--------|
| "yes" / "continue" / "next" | Proceed to next automation |
| "skip" | Skip current, mark as skipped, move to next |
| "stop" | Pause sprint, save state, offer to resume later |
| "redo" / "try again" | Retry the most recent automation |
| "change X" | Allow in-sprint plan modification (re-validate before re-executing) |

---

### Sprint Completion Report

After all automations processed, produce `.make/factory/{session_id}-report.md`:

```markdown
# Factory Run Report
**Session:** {session_id}
**Date:** {date}
**Total automations:** {n}

## Results

| # | Title | Status | Scenario ID | Monthly Ops |
|---|-------|--------|-------------|-------------|
| 1 | {title} | ✅ Built | {id} | ~{n} |
| 2 | {title} | ⚠️ Skipped | — | — |
| 3 | {title} | ❌ Failed | — | — |

## Built Successfully

### {title} (ID: {id})
- **Trigger:** {trigger}
- **Steps:** {n modules}
- **Monthly operations:** ~{n}
- **How to test:** {instructions}
- **Log:** .make/logs/{filename}

## Skipped / Failed

### {title}
- **Reason:** {plain-language}
- **Next step:** {recommendation}

## Portfolio Cost Estimate

| Item | Monthly |
|------|---------|
| New operations added | ~{n}/month |
| Estimated cost | ~${cost}/month |
| Previous monthly usage | ~{n}/month |
| New total | ~{n}/month |

## Audit Trail

All execution logs: `.make/logs/`
All changelogs: `.make/changelog/`
Session file: `.make/factory/{session_id}-session.json`
```

Return summary to orchestrator for display.

---

## Output Contract

Returns to orchestrator:
```json
{
  "built": [...],
  "skipped": [...],
  "failed": [...],
  "total_ops_added": 0,
  "report_path": ".make/factory/{session_id}-report.md"
}
```
