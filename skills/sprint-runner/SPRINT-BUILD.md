# Sprint Runner: Build Sequence and Report Format

## Per-Automation Build Sequence

For each automation `auto` in the approved list:

### Pre-Build Check

```
[{n} of {total}] Starting: {auto.title}
```

1. Check workspace map — does a duplicate scenario already exist? If yes: warn → user confirms or skips.
2. Check all required connections exist in `workspace.connections`. If missing: warn and confirm.

### Blueprint Construction

Before any Make.com calls, construct the scenario blueprint JSON in memory:
- Module flow (trigger + all steps)
- Error handler routes
- Data mappings
- Scheduling (if applicable)
- Metadata: name, description, team ID

### Narrated Build Steps

Narrate BEFORE every non-deterministic call:

**Step A — Create Scenario**
```
Creating the "{auto.title}" scenario in Make.com...
```
Call: `mcp__claude_ai_Make__scenarios_create` → capture `scenario_id`.

**Step B — Create Webhook (if trigger type = webhook)**
```
Setting up the webhook trigger for "{auto.title}"...
```
Call: `mcp__claude_ai_Make__hooks_create` → capture URL. Save to `.make/scenarios/{scenario_id}.json`.

**Step C — Verify Before Activation**
```
Checking the scenario looks correct before going live...
```
Call: `mcp__claude_ai_Make__scenarios_get` → inspect returned config. If validation fails: show issue → offer fix or skip.

**Step D — Activate**
```
Activating "{auto.title}" — this scenario will be live now...
```
Call: `mcp__claude_ai_Make__scenarios_activate`

**Step E — Final Verification**
Call: `mcp__claude_ai_Make__scenarios_get` → confirm `status === "active"`.

### Post-Build Actions

1. Write execution log → `.make/logs/{timestamp}-{slug}.json`
2. Write changelog entry → `.make/changelog/{scenario_id}.md`
3. Update `current-session.json` → mark `auto.status = "built"`
4. Show per-scenario confirmation and wait for user response before proceeding.

## Sprint Completion Report

After all automations processed, produce `.make/factory/{session_id}-report.md`:

```markdown
# Factory Run Report
**Session:** {session_id} / **Date:** {date} / **Total automations:** {n}

## Results
| # | Title | Status | Scenario ID | Monthly Ops |
|---|-------|--------|-------------|-------------|
| 1 | {title} | ✅ Built | {id} | ~{n} |
| 2 | {title} | ⚠️ Skipped | — | — |

## Built Successfully
### {title} (ID: {id})
- **Trigger:** {trigger} / **Steps:** {n modules}
- **Monthly operations:** ~{n}
- **How to test:** {instructions}
- **Log:** .make/logs/{filename}

## Skipped / Failed
### {title}
- **Reason:** {plain-language} / **Next step:** {recommendation}

## Portfolio Cost Estimate
| Item | Monthly |
|------|---------|
| New operations added | ~{n}/month |
| Estimated cost | ~${cost}/month |

## Audit Trail
All execution logs: `.make/logs/`
All changelogs: `.make/changelog/`
Session file: `.make/factory/{session_id}-session.json`
```
