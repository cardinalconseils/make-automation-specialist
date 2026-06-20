# /factory — System Design and Sprint Execution

Reference file for `commands/factory-phases.md`.

## Step 3 — SYSTEM DESIGN Phase

Announce: "Workspace mapped. Now designing all {n} automations..."

For EACH automation (show progress: "[1 of n] Designing: {title}"):
1. `mcp__claude_ai_Make__apps_recommend` — find best apps
2. `mcp__claude_ai_Make__app-module_get` for each module — get exact schemas
3. `mcp__claude_ai_Make__validate_blueprint_schema` — pre-validate
4. Call plan-builder skill → produce full AutomationPlan
5. Call cost-estimator skill → estimate operations + USD cost
6. Call compliance-scanner skill → flag data privacy issues
7. Call diagram-generator skill → Mermaid flowchart

After ALL designs complete, show the batch approval gate:

```
BATCH DESIGN REVIEW — {n} AUTOMATIONS READY TO BUILD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] {Title}  [Risk: Low]
{2-line summary | cost | compliance flags}
[diagram]

PORTFOLIO TOTAL: ~{ops}/month → ~${cost}/month

Type "build all" to start building in sequence.
Type "approve [1]" to approve individually.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

STOP HERE. Wait for explicit approval. Do not proceed to building.

## Step 4 — SPRINT Phase

After approval, announce:
```
Starting the build. I'll build one at a time and confirm before activating each.
```

For EACH approved automation (in order):
```
[{n} of {total}] Building: {title}...
```

1. Narrate: "Creating the {title} scenario in Make.com..."
2. `mcp__claude_ai_Make__scenarios_create` — create the scenario
3. If webhook needed: `mcp__claude_ai_Make__hooks_create`
4. Narrate: "Activating — this will go live now..."
5. `mcp__claude_ai_Make__scenarios_activate`
6. `mcp__claude_ai_Make__scenarios_get` — verify active status
7. Write log (execution-logger skill)
8. Write changelog (`.make/changelog/{id}.md`)

After each:
```
✅ [{n}/{total}] Built: {title}  (ID: {id})
   Test it by: {plain-language test instruction}
   Next: {title of next automation}  — ready? (yes / skip / stop)
```

On error: retry once → log + send Telegram alert + skip with note.

## Step 5 — Factory Report

Write `.make/factory/{session_id}-report.md` and display:

```
FACTORY RUN COMPLETE ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Built:    {n} scenarios (live in Make.com)
Skipped:  {n} (list with reasons)
Failed:   {n} (list with next steps)

Monthly cost added:  ~{ops} ops → ~${cost}/month

All logs: .make/factory/{session_id}-report.md
Next: run /audit to scan the new scenarios for any issues.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Update `current-session.json` → `status: "complete"`.
