# Intake: Artifacts 1–3

Part of `kickstart-intake`. See `INTAKE-ARTIFACTS.md` for file paths and order.

---

## Artifact 1 — context.md

```markdown
# Automation Project Context
**Generated:** {date}
**Project:** {descriptive project name derived from automations}

## Domain
{Business area these automations serve}

## Users
{Who will benefit and who will maintain them}

## Goals
{What the user is trying to achieve — plain language, not automation terms}

## Integrations Required
- {Service}: {how it's used}

## Constraints
{Budget limits, timing requirements, compliance concerns, data sensitivity}

## Automations in Scope ({n} total)
1. {title} — {trigger} → {action}
2. {title} — ...
```

---

## Artifact 2 — prd.md

```markdown
# Automation Project PRD
**Version:** 1.0 | **Date:** {date}

## Overview
{2-paragraph plain-language description of what this system does and why it matters}

## Automations

### {auto-001}: {title}
**Priority:** {1-n} | **Complexity:** {Low/Medium/High}

**User Story:**
As a {role}, I want {trigger event} to automatically {action}, so that {outcome}.

**Acceptance Criteria:**
- [ ] When {trigger condition}, {action} happens within {time expectation}
- [ ] If the automation fails, {error handling requirement}
- [ ] {Any data quality or compliance requirement}

**Inputs:** {data entering the automation}
**Outputs:** {what it produces or sends}
**Frequency:** {how often it runs}
**Cost:** ~{n} ops/month

---
### {auto-002}: ...
```

---

For Artifact 3 (erd.md) and Artifacts 4–6 (system-design.md, stack.md, ai-agents.md), see `INTAKE-ARTIFACTS-2.md`.
