---
description: Project discovery in plan mode — interviews you, writes a plan for review, then generates all artifacts on approval. Does NOT build.
argument-hint: Optional — describe your project idea or the first automation
---

# /kickstart — Make.com Project Discovery

> **Plan mode is entered automatically.** No files are written until you review
> and approve the project plan.

Routes to `kickstart-planner` agent.

---

## What Happens

**Phase 1 — Discovery (plan mode)**
- Claude enters plan mode immediately
- Interviews you about your automations (no Make.com API calls)
- Asks one question at a time; plain language throughout

**Phase 2 — Plan**
- Writes `.claude/plans/make-kickstart-{date}.md`
- Shows: automation portfolio, draft ERD, required connections, cost estimate, build order

**Phase 3 — Approval**
- You review the plan
- Reply to approve or request changes
- Nothing is written to `.make/` until you say go

**Phase 4 — Artifact Generation**
- `.make/context/context.md`
- `.make/prd.md`
- `.make/context/erd.md`
- `.make/context/system-design.md`
- `.make/context/stack.md`
- `.make/context/ai-agents.md` (only if AI required)

---

## Next Steps After Kickstart

```
• /factory  — full pipeline: bootstrap → design → build
• /plan {title}  — design a single automation
• /status  — check your Make.com workspace
```

---

## Hard Rules

- `EnterPlanMode` is always the first action — see `kickstart-discipline.md`
- No Make.com MCP calls during discovery and planning phases
- Never skip plan approval before writing artifacts
- If `.make/context/context.md` exists: ask before overwriting
