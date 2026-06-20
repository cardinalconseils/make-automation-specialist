---
name: database-builder
description: Builds Make.com data structures (JSON schemas) and data stores. Called during bootstrap gap analysis when automations require persistent storage, and on-demand during sprint. All writes are gated Level 1.
---

# Skill: database-builder

Scaffolds and manages Make.com data structures and data stores for automation projects.
Called by scenario-orchestrator when a gap analysis identifies storage requirements,
and by sprint-runner when a scenario needs a data store during build.

Detailed build steps: see `DATABASE-BUILD-STEPS.md`.

## Deterministic Classification

### Deterministic (call freely, no gate)
```
mcp__claude_ai_Make__data-structures_list    ← inventory existing schemas
mcp__claude_ai_Make__data-structures_get     ← inspect a schema
mcp__claude_ai_Make__data-stores_list        ← inventory existing stores
mcp__claude_ai_Make__data-stores_get         ← inspect a store
```

### Level 1 — Standard Write (gated by pre-execute hook)
```
mcp__claude_ai_Make__data-structures_create  ← define new JSON schema
mcp__claude_ai_Make__data-structures_update  ← modify existing schema
mcp__claude_ai_Make__data-stores_create      ← create new data store
mcp__claude_ai_Make__data-stores_update      ← modify store settings
```

### Level 3 — PROHIBITED in this skill
```
mcp__claude_ai_Make__data-structures_delete  ← never called here
mcp__claude_ai_Make__data-stores_delete      ← never called here
```

---

## When This Skill Is Called

1. **Bootstrap gap analysis** — orchestrator identifies automations that need storage
2. **Sprint pre-build check** — a scenario requires a data store that doesn't exist yet
3. **Direct user request** — user asks to set up storage for an automation

---

## Naming Conventions

- Use kebab-case: `processed-lead-ids`, `weekly-report-config`
- Include context: `{automation-slug}-{purpose}` (e.g., `lead-sync-processed-ids`)
- Avoid generic names: not `store-1`, not `data-structure-2`

---

## Output Contract

Returns to calling agent:
```json
{
  "created": [
    { "type": "data-store|data-structure", "id": "...", "name": "...", "purpose": "..." }
  ],
  "reused": [
    { "type": "data-store|data-structure", "id": "...", "name": "..." }
  ],
  "total_size_mb": 0
}
```
