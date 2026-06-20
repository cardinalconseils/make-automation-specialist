---
name: docs-researcher
description: Fetches exact Make.com module documentation before any blueprint is designed. Returns precise field names, required vs optional parameters, data types, and enumerated values. Eliminates improvisation and ensures first-shot accuracy.
---

# Make.com Docs Researcher

## Purpose

Never guess module parameters. Before writing a single module into a blueprint,
look up the exact specification.

Improvising field names wastes tokens, causes validation failures, and requires
multiple retries. One accurate lookup costs less than three failed attempts.

---

## When This Skill Is Required

Call this skill before:
- Designing any new scenario blueprint
- Adding a new module to an existing scenario
- Proposing a plan that references a specific Make.com app or module
- Writing any `scenarios_create` or `scenarios_update` payload

It is never optional. No exceptions.

---

## Lookup Sequence and Output Format

See [DOCS-RESEARCH-STEPS.md](./DOCS-RESEARCH-STEPS.md) for:
- The full 5-step lookup sequence (app → modules → spec → docs → extract)
- Multi-module scenario rules (look up all before designing)
- Blueprint validation calls after design
- Module Spec Card output format
- What to do when a module is not found

---

## Connection Verification

For each connection type identified in Step 3, verify it exists in the workspace:

```
mcp__claude_ai_Make__connections_list
  → filter for connections matching the required app
```

If the connection does not exist:
- Flag it in the plan as a prerequisite
- Do not attempt to create the scenario until the connection is confirmed
- Tell the user: "Before I can build this, you will need to connect [service]
  in Make.com. I'll walk you through that first."
