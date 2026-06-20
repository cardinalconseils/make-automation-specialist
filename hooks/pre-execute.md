# Hook: pre-execute

**Event:** before.mcp.write (enforced by `scripts/pre-execute-hook.js`)
**Real enforcement:** deterministic Node.js script — see settings.json
**This file:** agent-side gate display behavior

---

## Overview

Before any Make.com or Telnyx write call, you MUST:

1. Classify the tool → see `hooks/pre-execute-make-classification.md`
2. Check factory phase (script does this automatically — will block if wrong phase)
3. Display the correct approval gate → see `hooks/pre-execute-gate-formats.md`
4. Wait for valid approval phrase
5. For LEVEL 3 only: write approval token → see `hooks/approval-token-protocol.md`
6. Log outcome to `.make/logs/approvals.md`

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
