# Database Build Steps

Companion to `SKILL.md`. Five-step build process for data structures and data stores.

## Step 1 — Inventory Existing Storage

Always read before creating:

1. `mcp__claude_ai_Make__data-structures_list` → list all schemas
2. `mcp__claude_ai_Make__data-stores_list` → list all stores

If an existing structure/store satisfies the requirement: reuse it (never duplicate).
Show the user what exists and confirm reuse or create new.

## Step 2 — Identify Requirements

| Need | Storage Type |
|------|-------------|
| Track processed records (avoid duplicates) | Data store — key/value |
| Store configuration values | Data store — key/value |
| Log events or activity | Data store — structured |
| Pass data between scenarios | Data store — structured |
| Define data shape for multiple automations | Data structure (JSON schema) |

## Step 3 — Design the Schema (for data structures)

```json
{
  "name": "{descriptive-name}",
  "spec": [
    { "name": "field_name", "type": "text|number|boolean|date|email|url|array|collection", "required": true|false }
  ]
}
```

Field types: `text` strings/IDs · `number` counts/amounts · `boolean` flags ·
`date` timestamps · `email` validated email · `url` validated URL ·
`array` lists · `collection` nested objects

Present schema to user before creating:
```
DATA STRUCTURE DESIGN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name: {name}
Purpose: {plain-language what this stores}
Fields:
  • {field_name} ({type}) — {what it holds}
Used by: {which automations will read/write this}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 4 — Create (after gate approval)

**Creating data structure** — narrate, then call `mcp__claude_ai_Make__data-structures_create`
```
Creating the "{name}" data structure in Make.com...
```

**Creating data store** — narrate, then call `mcp__claude_ai_Make__data-stores_create`
```
Creating the "{name}" data store...
```

Parameters:
- `name`: descriptive slug (e.g., "processed-lead-ids", "onboarding-config")
- `datastructureId`: link to the data structure (for structured stores)
- `maxSizeMB`: start with 1MB unless automation volume requires more

## Step 5 — Verify and Log

After creation:
1. Call `mcp__claude_ai_Make__data-stores_get` or `mcp__claude_ai_Make__data-structures_get`
   to confirm it exists
2. Save metadata to `.make/scenarios/{id}-storage.json` if part of a scenario build
3. Surface to user:

```
✅ Storage ready: "{name}"
   ID: {id}   Type: {data store / data structure}
   How it's used: {plain-language}
```
