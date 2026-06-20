---
name: kickstart-plan
description: Writes the kickstart plan document from the collected portfolio. Called by kickstart-planner agent at end of Phase 2. Produces the plan file that the user reviews and approves before any artifacts are generated.
---

# Skill: kickstart-plan

Takes the portfolio collected during the discovery interview and writes a
structured plan document to `.claude/plans/make-kickstart-{YYYY-MM-DD}.md`.

This skill runs inside plan mode. The output is the ONLY file written before
the user approves. No `.make/` files are touched here.

## Deterministic Classification — Plan File Write Only

PERMITTED:
- Write to `.claude/plans/make-kickstart-{YYYY-MM-DD}.md`
- Read `.make/workspace.json` (to check existing connections)

BLOCKED:
- Any write to `.make/` (happens only after ExitPlanMode)
- Any `mcp__claude_ai_Make__*` call

---

## Input

Receives from kickstart-planner:
- `portfolio` — array of automation objects (from kickstart-intake output contract)
- `project` — `{ domain, users, goals, constraints }`
- `date` — today's date in YYYY-MM-DD format

---

## Execution

1. Load template from `PLAN-TEMPLATE.md`
2. Populate each section from intake data
3. Generate draft Mermaid ERD from service list
4. Estimate total ops/month (sum of per-automation estimates)
5. Determine build order (simple → complex, no unresolved dependencies first)
6. Write to `.claude/plans/make-kickstart-{date}.md`
7. Return file path to agent

---

## Sub-Files

| File | Contents |
|------|----------|
| `PLAN-TEMPLATE.md` | Exact markdown template for the plan document |
