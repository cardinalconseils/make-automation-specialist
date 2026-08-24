---
description: Post-kickstart build orchestrator. Reads the project backlog from .make/context/prd.md, lets you pick which scenarios to build, shows a cost-aware approval plan, then builds them in parallel.
argument-hint: Optional — scenario name or number to build (omit to choose from the backlog)
---

# /build — Build Scenarios From the Backlog

Dispatch to the **scenario-builder** agent.

This command assumes `/kickstart` or `/factory` has already run and produced
`.make/context/prd.md`. If that file does not exist, say so and point the user at
`/kickstart` — do not invent a backlog.

## Phase 0 — Read the backlog

1. Read `.make/context/prd.md` for the scenario list
2. Read `.make/workspace.json` for team and connection context
3. `mcp__claude_ai_Make__scenarios_list` — what already exists, so nothing is built twice

## Phase 1 — Let the user choose

Show the backlog as a numbered list with, for each item: what it does in one
plain-language line, the apps it needs, and whether every connection already
exists. Flag any scenario whose connections are missing — it can be built but not
activated.

If an argument was given, match it and skip straight to Phase 2.

## Phase 2 — Approval gate

Show the standard PLAN SUMMARY block from `CLAUDE.md` covering **all** selected
scenarios together, with a combined monthly operations estimate and cost.

Wait for explicit approval. Never build on assumed consent.

## Phase 3 — Build

Dispatch one **scenario-builder-worker** per approved scenario, in parallel.
Each worker owns exactly one scenario end to end: design, validate, push.

Build scenarios as **inactive**. Activation is a separate, explicit decision —
see `.claude/rules/destructive-ops.md`.

## Phase 4 — Report

Per scenario: name, ID, active state, connections still needed, and the next
action required from the user. Write the run to `.make/logs/`.

Then tell the user they can run `/next` to build the next item in the backlog.
