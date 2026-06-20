# Kickstart Discipline Rules

Enforces the plan-mode pattern for every `/kickstart` invocation.

---

## Rule 1 — Plan Mode Is Mandatory

`EnterPlanMode` MUST be the first tool call when `/kickstart` is invoked.
No questions, no reads, no MCP calls before entering plan mode.

Violation: writing any `.make/` file before `ExitPlanMode` is called.

---

## Rule 2 — Plan File Is the Only Write in Plan Mode

During plan mode, the ONLY permitted file write is:
`.claude/plans/make-kickstart-{YYYY-MM-DD}.md`

All artifact files (`.make/context/*.md`, `.make/prd.md`) are written AFTER approval.

---

## Rule 3 — No MCP Calls During Discovery

Phases 1–3 of kickstart-planner are discovery and planning only.
Zero `mcp__claude_ai_Make__*` calls until after artifact generation begins.

Exception: reading `.make/workspace.json` (already written by prior session).

---

## Rule 4 — Plan File Path Convention

```
.claude/plans/make-kickstart-YYYY-MM-DD.md
```

One plan file per kickstart session. If a plan file already exists for today,
append a `-2`, `-3` suffix rather than overwriting.

---

## Rule 5 — No Artifact Overwrite Without Consent

If `.make/context/context.md` already exists, ask before overwriting:
```
A project context already exists from {date}.
Overwrite it, or review and extend it?
```

---

## Verification Checklist

Before closing a kickstart session, confirm:
- [ ] Plan file exists at `.claude/plans/make-kickstart-{date}.md`
- [ ] All 5+ artifacts written to `.make/context/` and `.make/prd.md`
- [ ] Session note appended to `.make/memory/facts.md`
- [ ] No MCP write calls were made during phases 1–3
