---
name: blueprint-fetch
description: "Fetches the current live blueprint from Make API and saves it as the authoritative local file before any editing begins. Entry point for the local-edit workflow."
allowed-tools: Bash, Read, Write
---

# Blueprint Fetch Skill

## Purpose
Pull the live blueprint from Make.com into a local JSON file before any editing. Ensures local state matches Make's actual state and creates a clear source of truth for the edit → push cycle.

## Protocol

### Step 1 — Identify scenario
Confirm from context or ask:
- Scenario ID (use `.make/context/workspace.json` `scenarios[].id` if available)
- Make region: `eu1` or `us1` (default: `eu1`)
- Save path: `.make/scenarios/{scenarioId}.json` (default)

### Step 2 — Fetch blueprint
```bash
curl -s -X GET \
  "https://{region}.make.com/api/v2/scenarios/{scenarioId}" \
  -H "Authorization: Token ${MAKE_API_KEY}" \
  | jq .
```

Capture full response. Do not discard it.

### Step 3 — Save blueprint
Extract the `scenario.blueprint` object and save:
```bash
curl -s "https://{region}.make.com/api/v2/scenarios/{scenarioId}" \
  -H "Authorization: Token ${MAKE_API_KEY}" \
  | jq '.scenario.blueprint' > .make/scenarios/{scenarioId}.json
```

Create `.make/scenarios/` if it does not exist.

### Step 4 — Report
```
✅ Blueprint fetched
Scenario: {name} ({id})
Last edited: {lastEdit timestamp from response}
Modules: {count of flow[] entries}
Saved: .make/scenarios/{id}.json
→ Edit this file locally, then run /blueprint-push when ready.
```

### Step 5 — Next step instruction
Always end with:
> This file is now the source of truth. Edit `.make/scenarios/{id}.json`, then run `/blueprint-push`. Do not edit the scenario in Make's UI while working locally — it will create a sync conflict.

## Rules
- Never start editing without fetching first in the current session
- If a `.make/scenarios/{id}.json` already exists, ask: "A local file exists. Overwrite with latest from Make, or continue with the existing file?"
- If the API returns non-200: report the HTTP status and error body, then stop
- MAKE_API_KEY must come from environment — never hardcode it
