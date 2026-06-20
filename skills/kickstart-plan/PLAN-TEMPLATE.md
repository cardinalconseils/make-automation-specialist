---
name: kickstart-plan-template
description: Markdown template for the Make.com kickstart plan document. Populated by kickstart-plan skill and written to .claude/plans/.
---

# Make.com Project Kickstart Plan — {YYYY-MM-DD}

> **Status:** Awaiting approval — no files have been written yet.
> Approve this plan to generate all project artifacts.

---

## Project Overview

**Domain:** {business area — e.g. "e-commerce order processing"}
**Users:** {who triggers automations} / {who maintains them}
**Goals:** {2–3 plain-language objectives}
**Constraints:** {budget, timing, compliance flags, data sensitivity}

---

## Automation Portfolio

| # | Title | Trigger | Action | Complexity | Est. Ops/Month |
|---|-------|---------|--------|------------|----------------|
| {n} | {title} | {trigger} | {action} | Low / Med / High | ~{N} |

**Total estimated operations:** ~{total}/month
**Estimated Make.com cost:** ~${X}/month at current plan rates

---

## Artifacts That Will Be Generated

- [ ] `.make/context/context.md` — project domain, users, goals, integrations
- [ ] `.make/prd.md` — full PRD with user stories and acceptance criteria
- [ ] `.make/context/erd.md` — data flow diagram (Mermaid)
- [ ] `.make/context/system-design.md` — architecture, triggers, dependencies
- [ ] `.make/context/stack.md` — required apps, connections, API keys
- [ ] `.make/context/ai-agents.md` — AI agent inventory *(only if AI required)*

---

## Draft Data Flow

```mermaid
flowchart LR
  {source_1}([{source_1}]) --> Make.com
  {source_2}([{source_2}]) --> Make.com
  Make.com --> {destination_1}([{destination_1}])
  Make.com --> {destination_2}([{destination_2}])
```

---

## Required Connections

| Service | Connection Name | Purpose |
|---------|----------------|---------|
| {service} | {name} | {what it does} |

---

## Build Order

{sequence with one-line rationale}

1. {auto-001} — {reason: no dependencies, simplest}
2. {auto-002} — {reason: depends on connection from #1}

---

## Approval

Reply **approve** (or any confirmation) to generate all artifacts.
Reply with changes to adjust before generating.
