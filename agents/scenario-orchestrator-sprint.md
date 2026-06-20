# Scenario Orchestrator — Phase 3: Sprint Execution

For enforcement rules, see `scenario-orchestrator-enforcement.md`.

## Phase 3 — SPRINT: Build All Approved Scenarios

Goal: build each approved automation sequentially, with per-scenario approval gates.

Announce:
```
BUILDING YOUR AUTOMATION FACTORY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Building {n} automations in sequence.
I'll confirm each one before activating.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Per-Scenario Sprint

```
[{n} of {total}] BUILDING: {title}
```

**Build Checklist:**
1. Verify connection prerequisites (from workspace map)
2. Create scenario via `mcp__claude_ai_Make__scenarios_create`
   - Narrate: "Creating {title} scenario..."
3. If scenario needs a webhook: create via `mcp__claude_ai_Make__hooks_create`
   - Narrate: "Setting up the webhook trigger..."
4. Activate via `mcp__claude_ai_Make__scenarios_activate`
   - Narrate: "Activating — this scenario is going live now..."
5. Fetch back via `mcp__claude_ai_Make__scenarios_get` → verify it's active
6. Write execution log (execution-logger skill)
7. Write changelog entry to `.make/changelog/{scenario_id}.md`

**Per-Scenario Confirmation:**
```
✅ [{n}/{total}] BUILT: {title}
   Scenario ID: {id}
   Status: Active
   How to test: {plain-language test instruction}
   
   Ready to build [{n+1}/{total}]: {next title}? (yes/skip/stop)
```

**Error handling per scenario:**
- On error: load `failure-diagnostician` skill → classify against taxonomy → cite code → apply fix
- If taxonomy fix resolves: retry once, then continue sprint
- If retry fails: dispatch `failure-diagnostician` agent for deep diagnosis
- Write classified error to `.make/logs/`, skip to next, flag in report with taxonomy code
- If ≥2 consecutive failures: send Telegram alert via `mcp__telnyx__send_message`, pause
  sprint, surface to user with classified error codes

### Sprint Complete

```
FACTORY RUN COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Built: {n} scenarios
⚠️  Skipped: {n} scenarios (see notes below)
❌ Failed: {n} scenarios

BUILT SUCCESSFULLY
{list with scenario IDs and test instructions}

SKIPPED / NEEDS ATTENTION
{list with reasons}

TOTAL MONTHLY COST
~{total_ops} operations/month → ~${cost}/month

Audit trail: .make/factory/{session_id}-report.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Save final factory report to `.make/factory/{session_id}-report.md`.
Update `current-session.json` → `status: complete`.

---

## Formula Expressions

When writing any module field expression in a blueprint:
1. Load `skills/formula-expert/SKILL.md` before writing expressions
2. Always use semicolons as argument separators: `{{fn(a; b)}}`
3. Never guess function names — verify in the skill

## Telnyx / SMS / Voice Note

If any automation outputs SMS or makes voice calls:
- Build the Make.com side of the scenario normally
- After sprint, note: "The Telnyx side (phone numbers, messaging profiles, call routing) needs
  to be configured separately. Run /telnyx to complete the communications setup."
- Do NOT attempt to configure Telnyx directly — route to telnyx-agent.
