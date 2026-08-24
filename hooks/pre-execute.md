# Hook: pre-execute

**Event:** before.mcp.write (enforced by `scripts/pre-execute-hook.js`)
**Real enforcement:** deterministic Node.js script — see settings.json
**This file:** agent-side gate display behavior

---

## Overview

Before any Make.com or Telnyx write call, you MUST:

1. Classify the tool → see `hooks/pre-execute-make-classification.md`
2. Check factory phase (script does this automatically — will block if wrong phase)
3. For `scenarios_create` / `scenarios_update`: run the `blueprint-review` skill and
   write the review sentinel first (script blocks otherwise — see Review Gate below)
4. Display the correct approval gate → see `hooks/pre-execute-gate-formats.md`
5. Wait for valid approval phrase
6. For LEVEL 3 only: write approval token → see `hooks/approval-token-protocol.md`
7. Log outcome to `.make/logs/approvals.md`

---

## Review Gate (hard, deterministic)

`scripts/pre-execute-hook.js` blocks `mcp__claude_ai_Make__scenarios_create` and
`..._update` unless `.make/logs/.blueprint-reviewed` satisfies **all** of:

| Condition | Why |
|---|---|
| Exists and parses as JSON | Legacy `touch` sentinels are rejected — they could not prove *which* blueprint was reviewed |
| `ts` less than 24h old | A review goes stale |
| `verdict` is not `FIX FIRST` | The reviewer already said no |
| `hash` equals sha256 of the blueprint in the call | The reviewed bytes are the pushed bytes |

Write it with the script, never by hand — it shares the gate's canonicalizer:

```bash
PR="${CLAUDE_PLUGIN_ROOT:-$HOME/Documents/DEV/make.com}"
node "$PR/scripts/blueprint-sentinel.js" <blueprint.json> "<VERDICT>" "<scenario>"
```

Edit the blueprint after reviewing → the hash no longer matches → re-review. That is the
gate working, not a bug. It cannot be bypassed by agent reasoning.

For Telnyx tools: see `hooks/pre-execute-telnyx.md`

---

## Approval Log Entry

After every gate (approved, refused, or cancelled), append to `.make/logs/approvals.md`:

```markdown
## {timestamp}
Tool: {tool name}
Risk level: LEVEL 1 / LEVEL 2 / LEVEL 3
Resource: {name or id}
Agent: {which agent or command requested this}
Factory phase: {kickstart/bootstrap/design/sprint/none}
Outcome: {approved | refused | blocked-wrong-phase | cancelled}
```

---

## Enforcement Scope

Applies to all agents: automation-specialist, scenario-orchestrator,
scenario-auditor, automation-planner, telnyx-agent, and all skills and commands.

No agent or skill can bypass the hook. The script exits 2 (blocked) if:
- Factory session is in kickstart/bootstrap/design phase
- A LEVEL 3 call has no valid approval token

---

## SAFE Operations (no gate required)

Read-only MCP calls pass through without any gate. See classification file for
the full list. Never show approval gates for reads.
