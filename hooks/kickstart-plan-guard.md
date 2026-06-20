---
id: kickstart-plan-guard
event: PreToolUse:Write
script: scripts/kickstart-plan-guard.js
description: Deterministic artifact gate. Blocks writes to .make/context/ and .make/prd.md unless a kickstart plan exists for today. Cannot be bypassed by agent reasoning.
---

# Hook: Kickstart Plan Guard

Fires on every `Write` tool call. If the target path is a kickstart artifact
(`.make/context/*.md` or `.make/prd.md`), the write is blocked unless a plan
file named `make-kickstart-{YYYY-MM-DD}*.md` exists in `.claude/plans/`.

## Why This Exists

Agent instructions ("call EnterPlanMode first") are probabilistic — a model
under pressure can skip the step. This hook enforces the same gate in code:
no plan file = no artifacts, unconditionally.

## What It Blocks

- `.make/context/context.md`
- `.make/context/erd.md`
- `.make/context/system-design.md`
- `.make/context/stack.md`
- `.make/context/ai-agents.md`
- `.make/prd.md`

## What It Allows Through

- Any write outside `.make/context/` or `.make/prd.md`
- Writes to the plan file itself (`.claude/plans/make-kickstart-*.md`)
- Writes to `.make/memory/`, `.make/logs/`, etc.

## How to Pass the Gate

1. Run `/kickstart`
2. Complete the discovery interview (plan mode)
3. Review and approve the plan
4. Artifact generation runs — plan file now exists, gate opens
