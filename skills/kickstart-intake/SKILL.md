---
name: kickstart-intake
description: Automation portfolio discovery interview. Guides the user to articulate every automation they need before any design begins. Produces a prioritized portfolio list. Called by scenario-orchestrator during the Kickstart phase.
---

# Skill: kickstart-intake

Conducts a conversational interview to discover the full portfolio of automations
the user needs. Returns a prioritized, structured list of automation requirements.

Called by the scenario-orchestrator at the start of a `/factory` run.
Never design or build during this skill — only discover.

## Deterministic Classification — This Skill Is Read-Only

This skill makes ZERO Make.com MCP calls. It is pure conversation and file writes.
All operations here are deterministic. No approval gates apply.

Permitted operations:
- AskUserQuestion (conversational intake)
- Read / Write (session file, output docs)
- Bash (read `.make/workspace.json` if already available)

BLOCKED operations (must never be called in this skill):
- Any `mcp__claude_ai_Make__*` tool call
- Any non-deterministic operation

If you find yourself about to call a Make.com MCP tool during kickstart-intake,
you are in the wrong skill. Stop and return to the orchestrator.

---

## Input Contract

Receives from orchestrator:
- `seed` (optional) — an initial automation idea if the user provided one
- `existing_automations` — list from workspace map (to avoid duplicates)

---

## Sub-Files

| File | Contents |
|------|----------|
| `INTAKE-QUESTIONS.md` | Interview protocol — opening prompts, collection loop, AI detection, complexity classifier, priority ranker |
| `INTAKE-ARTIFACTS.md` | Artifact generation — context.md, prd.md, erd.md, system-design.md, stack.md, ai-agents.md |
| `INTAKE-OUTPUTS.md` | Output contract JSON, portfolio display format, edge cases |

---

## Execution Order

1. Run discovery interview → see `INTAKE-QUESTIONS.md`
2. Display portfolio for user confirmation → see `INTAKE-OUTPUTS.md` (Portfolio Display)
3. Generate project artifacts → see `INTAKE-ARTIFACTS.md`
4. Return JSON to orchestrator → see `INTAKE-OUTPUTS.md` (Output Contract)
