---
name: database-builder
description: Builds Make.com data structures (JSON schemas) and data stores. Called during bootstrap gap analysis when automations require persistent storage, and on-demand during sprint. All writes are gated Level 1.
---

# Skill: database-builder

Scaffolds and manages Make.com data structures and data stores for automation projects.
Called by scenario-orchestrator when a gap analysis identifies storage requirements,
and by sprint-runner when a scenario needs a data store during build.

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

## Step 1 — Inventory Existing Storage

Always read before creating. Check what already exists:

```
Checking existing data structures and stores...
```

1. `mcp__claude_ai_Make__data-structures_list` → list all schemas
2. `mcp__claude_ai_Make__data-stores_list` → list all stores

If an existing structure/store can satisfy the requirement: reuse it (never duplicate).
Show the user what already exists and confirm reuse or create new.

---

## Step 2 — Identify Requirements

From the automation design, extract storage requirements:

| Need | Storage Type |
|------|-------------|
| Track processed records (avoid duplicates) | Data store — key/value |
| Store configuration values | Data store — key/value |
| Log events or activity | Data store — structured |
| Pass data between scenarios | Data store — structured |
| Define data shape for multiple automations | Data structure (JSON schema) |

---

## Step 3 — Design the Schema (for data structures)

Before creating a data structure, define the JSON schema from the automation's data requirements:

```json
{
  "name": "{descriptive-name}",
  "spec": [
    { "name": "field_name", "type": "text|number|boolean|date|email|url|array|collection", "required": true|false }
  ]
}
```

**Field type selection:**
- `text` — strings, IDs, names
- `number` — counts, amounts, quantities
- `boolean` — flags, status switches
- `date` — timestamps, dates
- `email` — validated email addresses
- `url` — validated URLs
- `array` — lists of values
- `collection` — nested objects

Present schema to user before creating:
```
DATA STRUCTURE DESIGN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name: {name}
Purpose: {plain-language what this stores}
Fields:
  • {field_name} ({type}) — {what it holds}
  • {field_name} ({type}) — {what it holds}

Used by: {which automations will read/write this}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 4 — Create (after gate approval)

Narrate before each call:

**Creating data structure:**
```
Creating the "{name}" data structure in Make.com...
```
Call: `mcp__claude_ai_Make__data-structures_create`

**Creating data store:**
```
Creating the "{name}" data store...
```
Call: `mcp__claude_ai_Make__data-stores_create`

Parameters:
- `name`: descriptive slug (e.g., "processed-lead-ids", "onboarding-config")
- `datastructureId`: link to the data structure (for structured stores)
- `maxSizeMB`: start with 1MB unless automation volume requires more

---

## Step 5 — Verify and Log

After creation:
1. Call `mcp__claude_ai_Make__data-stores_get` or `mcp__claude_ai_Make__data-structures_get` → confirm exists
2. Save metadata to `.make/scenarios/{id}-storage.json` if part of a scenario build
3. Surface to user:

```
✅ Storage ready: "{name}"
   ID: {id}
   Type: {data store / data structure}
   How it's used: {plain-language}
```

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
