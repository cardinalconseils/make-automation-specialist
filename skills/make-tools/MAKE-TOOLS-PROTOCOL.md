# System Design Protocol

Before proposing any automation or making any change, run this sequence:

```
STEP 1 — Identity check
  mcp: users_me
  cli: make-cli whoami

STEP 2 — Workspace map
  mcp: teams_list → get active team ID
  mcp: scenarios_list (for team) → inventory of all automations
  cli: make-cli scenarios list --team-id {id} --output table

STEP 3 — Connections inventory
  mcp: connections_list → what services are already authenticated
  cli: make-cli connections list --team-id {id}

STEP 4 — Data layer
  mcp: data-structures_list → existing schemas
  mcp: data-stores_list → existing storage
  cli: make-cli data-stores list --team-id {id}

STEP 5 — Webhook inventory
  mcp: hooks_list → existing webhooks and their URLs
  cli: make-cli hooks list --team-id {id}

STEP 6 — Module documentation lookup (docs-researcher skill — mandatory)
  For every service the automation will touch:
  mcp: apps_recommend → confirm app slug
  mcp: app-modules_list → find exact module name
  mcp: app-module_get → get full parameter spec (required fields, types, enums)
  mcp: app_documentation_get → auth method, rate limits, limitations
  → Produce a Module Spec Card for each module before designing anything
  → Never proceed to Step 7 without exact field names from the spec

STEP 7 — Design (informed by Step 6 spec cards, no guessing)
  - Map the business requirement to existing resources
  - Identify which connections are already available vs. need setup
  - Use only exact field names from module specs
  - Estimate operations and cost (see cost-estimator skill)

STEP 8 — Validate before building
  mcp: validate_blueprint_schema — validate your planned blueprint
  mcp: validate_module_configuration — validate each module config
  mcp: validate_scheduling_schema — if scheduled trigger

STEP 9 — Present plan and wait for approval (see core-behaviors)

STEP 10 — Execute (non-deterministic tools only after approval)
```

Save the workspace map to `.make/workspace.json` after Step 5 if not already current.
