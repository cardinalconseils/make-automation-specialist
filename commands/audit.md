---
description: Audit Make.com scenarios for errors, missing error handlers, inefficiencies, compliance risks, and cost issues. Proposes ranked fixes and executes after approval.
argument-hint: Optional — scenario name or ID to audit (omit for full workspace audit)
---

# /audit — Audit Make.com Scenarios

## Phase 0 — System Design First

Before auditing anything, map the full workspace (deterministic reads only):

1. `mcp__claude_ai_Make__scenarios_list` — full inventory
2. `mcp__claude_ai_Make__connections_list` — available connections (detects broken ones)
3. `mcp__claude_ai_Make__hooks_list` — existing webhooks

If an argument was provided, target that scenario. Otherwise ask:
- "Should I audit one scenario or all of them?"
- For bulk: "This may take a few minutes — want me to proceed?"

## Phase 1 — Fetch (Deterministic)

For each scenario in scope:
1. `mcp__claude_ai_Make__scenarios_get` — fetch full blueprint
2. `mcp__claude_ai_Make__extract_blueprint_components` — parse structure
3. `mcp__claude_ai_Make__executions_list` — recent run history (success rate, errors)
4. Save snapshot to `.make/scenarios/{id}.json`

Progress indicator for bulk: "Fetching scenario {n} of {total}: {name}..."

## Phase 2 — Analyze

Full checklist and scoring criteria: see `commands/audit-checklist.md`

## Phase 3 — Report

Save to `.make/audits/{YYYY-MM-DD-HHmm}-audit.md`. Generate Mermaid diagram for each
scenario with issues (diagram-generator skill). Save to `.make/diagrams/`.

## Phase 4 — Fix Proposal (Approval Gate)

Present grouped fix plan with three approval options:
- "Fix all critical issues" — one approval for the critical batch
- "Fix all issues" — critical + warnings in one approval
- "Walk me through each" — step through fixes one by one

Do not execute any fix until the user approves.

## Phase 5 — Execute Fixes (Non-Deterministic, After Approval)

For each approved fix:
1. Get fresh blueprint: `mcp__claude_ai_Make__scenarios_get` (backup current state)
2. Apply fix: `mcp__claude_ai_Make__scenarios_update`
3. Validate: re-fetch and confirm change applied
4. Write changelog: `.make/changelog/{scenario-id}.md`

For broken connections: guide user through reconnection (requires UI auth).

## Phase 6 — Debrief

```
AUDIT COMPLETE
Fixed: {n} critical, {n} warnings
Remaining: {list anything not fixed and why}
Next recommended audit: {date}
Telegram alerts: active ✅
```
