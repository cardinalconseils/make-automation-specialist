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

## Phase 2 — Analyze (Deterministic)

For each scenario, check every item below. Mark CRITICAL / WARNING / INFO.

**Reliability**
- [ ] HTTP/API modules missing error handler → CRITICAL
- [ ] No retry logic on network-dependent modules → WARNING
- [ ] Trigger re-triggers itself (infinite loop risk) → CRITICAL
- [ ] Hard-coded credentials or API keys in module config → CRITICAL
- [ ] Unhandled null/empty data paths → WARNING

**Observability**
- [ ] No error notification path (nothing alerts on failure) → CRITICAL
- [ ] No logging of key outcomes → WARNING
- [ ] No data validation before processing → WARNING

**Efficiency**
- [ ] High operation count — modules that can be consolidated → WARNING
- [ ] Full record fetched when only one field needed → WARNING
- [ ] No filter module before expensive downstream operations → WARNING
- [ ] Polling trigger where webhook alternative exists → INFO
- [ ] Duplicate scenario doing the same work → WARNING

**Connections**
- [ ] Verify each connection used is still active → CRITICAL if broken
- `make-cli connections verify --connection-id {id}` for each

**Compliance** — call compliance-scanner skill for each scenario

## Phase 3 — Report

Generate structured audit report. Save to `.make/audits/{YYYY-MM-DD-HHmm}-audit.md`.

```
AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date: {timestamp}
Scenarios analyzed: {n}

SUMMARY
  🔴 Critical issues: {n}    (fix immediately — automation may break)
  🟡 Warnings: {n}           (fix when possible — reduces risk)
  🔵 Info: {n}               (nice to have)

CRITICAL ISSUES
  [Scenario Name]
  Issue: {plain-language description}
  Why it matters: {impact if not fixed}
  Proposed fix: {what I will do, in plain language}
  Risk of fix: Low

WARNINGS
  ...

COMPLIANCE
  ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Generate a Mermaid diagram for each scenario with issues (diagram-generator skill).
Save to `.make/diagrams/`.

## Phase 4 — Fix Proposal (Approval Gate)

Present grouped fix plan with three approval options:
- "Fix all critical issues" — one approval for the critical batch
- "Fix all issues" — critical + warnings in one approval
- "Walk me through each" — step through fixes one by one

Each fix shown as:
```
FIX #{n}
Scenario: {name}
Issue: {short description}
What I'll change: {plain-language}
Risk: Low / Medium
Operations impact: {+/- n}/month
```

**Do not execute any fix until the user approves.**

## Phase 5 — Execute Fixes (Non-Deterministic, After Approval)

For each approved fix:
1. Get fresh blueprint: `mcp__claude_ai_Make__scenarios_get` (backup current state)
2. Apply fix: `mcp__claude_ai_Make__scenarios_update`
3. Validate: re-fetch and confirm change applied
4. Write changelog: `.make/changelog/{scenario-id}.md`

For broken connections: guide user through reconnection (cannot be scripted — requires UI auth).

## Phase 6 — Debrief

```
AUDIT COMPLETE
Fixed: {n} critical, {n} warnings
Remaining: {list anything not fixed and why}
Next recommended audit: {date}
Telegram alerts: active ✅
```
