---
name: make-tools
description: Complete reference for all Make.com tools available via MCP and CLI. Classifies every operation as deterministic (read-only, safe) or non-deterministic (write, side effects, requires approval). Defines tool selection rules and system design protocol.
---

# Make.com Tool Reference

## Module Selection Rule — Native First, Always

**Never use the HTTP module if a native Make.com module exists for the service.**

This is a hard rule, not a preference.

| Situation | Wrong | Right |
|-----------|-------|-------|
| Sending a Slack message | HTTP module → POST to Slack API | Slack → Send a Message |
| Creating a Google Sheet row | HTTP module → POST to Sheets API | Google Sheets → Add a Row |
| Sending an email via Gmail | HTTP module → Gmail REST API | Gmail → Send an Email |
| Creating a HubSpot contact | HTTP module → POST to HubSpot API | HubSpot → Create a Contact |

**Why this matters:**
- Native modules handle OAuth refresh automatically — HTTP modules break when tokens expire
- Native modules are typed — fields are validated at design time, not at runtime
- Native modules count as 1 operation — HTTP modules still count as 1 but are harder to debug
- Native modules show in the connections list — HTTP modules hide auth complexity and make auditing harder
- Make.com support covers native modules — custom HTTP calls are your responsibility

**Before designing any automation step:**
1. Call `mcp__claude_ai_Make__apps_recommend` with the service name
2. Call `mcp__claude_ai_Make__app-modules_list` to see all available modules for that app
3. Call `mcp__claude_ai_Make__app_documentation_get` for module-level docs
4. Only if no native module exists: use HTTP module, and document why in the plan

**HTTP module is acceptable only when:**
- The service has no Make.com app at all
- The specific API endpoint has no matching native module (e.g., a new endpoint added after the app was built)
- The user explicitly requires it for a one-time integration with an internal/custom API

When HTTP is unavoidable, always name it clearly in the plan: "There is no native module for [service/endpoint], so we will use an HTTP call. This means we will need to manage authentication manually."

---

## Tool Selection Rule — MCP vs CLI

**MCP first.** Use MCP tools by default — they return structured data, handle auth automatically, and are fully typed.

**Use the CLI (`make-cli`) when:**
- Doing bulk operations on many scenarios at once (scripting loops)
- MCP tool is unavailable or returning errors
- You need raw blueprint JSON for file-based manipulation
- Setting up SDK apps (custom app development)

**Use both together when:** reading with MCP (richer schema), then piping result to CLI for batch processing.

---

## System Design Protocol — Always Do This First

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

STEP 8 — Present plan and wait for approval (see core-behaviors)

STEP 9 — Execute (non-deterministic tools only after approval)
```

Save the workspace map to `.make/workspace.json` after Step 5 if not already current.

---

## MCP Tools — Deterministic (Read-Only, Safe)

These can be called freely without approval. They read state, they do not change it.

### Scenarios
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__scenarios_list` | All scenarios for a team with status, schedule, last run |
| `mcp__claude_ai_Make__scenarios_get` | Full blueprint + metadata for one scenario |
| `mcp__claude_ai_Make__scenarios_interface` | Input/output interface definition for a scenario |
| `mcp__claude_ai_Make__extract_blueprint_components` | Parses a blueprint into structured module list |
| `mcp__claude_ai_Make__extract_module_components` | Parses a single module's configuration |

### Executions
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__executions_list` | Run history for a scenario |
| `mcp__claude_ai_Make__executions_get` | Summary of one execution |
| `mcp__claude_ai_Make__executions_get-detail` | Full execution log with module-by-module results |

### Connections
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__connections_list` | All authenticated connections for a team |
| `mcp__claude_ai_Make__connections_get` | Details of one connection |
| `mcp__claude_ai_Make__connection-metadata_get` | Schema and capabilities of a connection type |

### Webhooks / Hooks
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__hooks_list` | All webhooks and mailhooks |
| `mcp__claude_ai_Make__hooks_get` | One webhook's details and URL |
| `mcp__claude_ai_Make__hook-config_get` | Full config schema for a hook type |
| `mcp__claude_ai_Make__hook-metadata_get` | Metadata and capabilities |

### Data Layer
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__data-stores_list` | All data stores |
| `mcp__claude_ai_Make__data-stores_get` | One data store's config |
| `mcp__claude_ai_Make__data-store-records_list` | Records in a data store |
| `mcp__claude_ai_Make__data-structures_list` | All data structures (schemas) |
| `mcp__claude_ai_Make__data-structures_get` | One data structure's schema |

### Apps & Modules (Discovery)
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__apps_recommend` | Suggests Make.com apps for a use case |
| `mcp__claude_ai_Make__app_documentation_get` | Full docs for an app |
| `mcp__claude_ai_Make__app-modules_list` | All modules for an app |
| `mcp__claude_ai_Make__app-module_get` | One module's full schema and config |

### Validation (Always run before creating)
| Tool | What it validates |
|------|------------------|
| `mcp__claude_ai_Make__validate_blueprint_schema` | Full scenario blueprint JSON |
| `mcp__claude_ai_Make__validate_module_configuration` | One module's config |
| `mcp__claude_ai_Make__validate_epoch_configuration` | Scheduling configuration |
| `mcp__claude_ai_Make__validate_hook_configuration` | Webhook configuration |
| `mcp__claude_ai_Make__validate_scenario_interface` | Scenario input/output interface |
| `mcp__claude_ai_Make__validate_scheduling_schema` | Schedule definition |

### Account & Organization
| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__users_me` | Current authenticated user |
| `mcp__claude_ai_Make__teams_list` | All teams for the org |
| `mcp__claude_ai_Make__teams_get` | One team's details |
| `mcp__claude_ai_Make__organizations_list` | All organizations |
| `mcp__claude_ai_Make__organizations_get` | One org's details |
| `mcp__claude_ai_Make__folders_list` | Scenario folders |
| `mcp__claude_ai_Make__keys_list` / `keys_get` | API keys |
| `mcp__claude_ai_Make__enums_countries` / `regions` / `timezones` | Reference data |
| `mcp__claude_ai_Make__credential-requests_list` / `get` | Pending credential requests |

---

## MCP Tools — Non-Deterministic (Write / Side Effects)

**These require approval before calling. Log every call via execution-logger skill.**

### Risk Levels

**LEVEL 1 — Standard write** (reversible with effort, show plan + get approval)
- `scenarios_create` — creates a new inactive scenario
- `scenarios_update` — modifies blueprint (get backup first with scenarios_get)
- `scenarios_activate` — makes scenario live
- `scenarios_deactivate` — pauses scenario
- `scenarios_set-interface` — updates I/O interface
- `hooks_create` / `hooks_update`
- `data-stores_create` / `data-stores_update`
- `data-structures_create` / `data-structures_update` / `data-structures_generate`
- `folders_create` / `folders_update`
- `data-store-records_create` / `data-store-records_update` / `data-store-records_replace`
- `credential-requests_create` / `credential-requests_create-by-credentials`
- `credential-requests_extend-connection`
- `tools_create` / `tools_update`
- `teams_create` / `teams_update`
- `organizations_create` / `organizations_update`

**LEVEL 2 — HIGH RISK** (real-world effects, cannot be easily undone)
- `scenarios_run` — executes a live scenario. May send emails, charge money, post data, modify external systems. Always confirm scope and test with safe data first.
- `rpc_execute` — executes a remote procedure with unknown side effects. Use only when explicitly instructed and you understand exactly what the RPC does.

**LEVEL 3 — DESTRUCTIVE** (irreversible, Make.com has no recycle bin)
- `scenarios_delete`
- `hooks_delete`
- `data-stores_delete`
- `data-store-records_delete`
- `data-structures_delete`
- `folders_delete`
- `keys_delete`
- `credential-requests_delete`
- `credential-requests_credential-delete`
- `teams_delete`
- `organizations_delete`

**For LEVEL 3: always get the current state first (backup), show the user exactly what will be lost, require explicit typed confirmation (e.g., "DELETE Lead Intake Webhook").**

---

## CLI Tools — Deterministic (Read-Only, Safe)

```bash
# Identity
make-cli whoami

# Scenarios
make-cli scenarios list --team-id {id}
make-cli scenarios get --scenario-id {id}
make-cli scenarios interface --scenario-id {id}

# Executions
make-cli executions list --scenario-id {id}
make-cli executions get --execution-id {id}
make-cli executions get-detail --execution-id {id}
make-cli incomplete-executions list --team-id {id}

# Connections
make-cli connections list --team-id {id}
make-cli connections get --connection-id {id}

# Webhooks
make-cli hooks list --team-id {id}
make-cli hooks get --hook-id {id}

# Data
make-cli data-stores list --team-id {id}
make-cli data-stores get --data-store-id {id}
make-cli data-store-records list --data-store-id {id}

# SDK Apps (custom app development)
make-cli sdk-apps list
make-cli sdk-apps get --app-name {name} --version {v}
make-cli sdk-apps get-section --app-name {name} --section {section}
make-cli sdk-apps get-docs --app-name {name}
make-cli sdk-modules list --app-name {name}
make-cli sdk-functions list --app-name {name}
make-cli sdk-rpcs list --app-name {name}
make-cli sdk-webhooks list --app-name {name}

# Reference
make-cli enums countries
make-cli enums timezones
```

---

## CLI Tools — Non-Deterministic (Write / Side Effects)

Same risk levels as MCP. Require approval before running.

```bash
# LEVEL 1 — Standard write
make-cli scenarios create --blueprint {json}
make-cli scenarios update --scenario-id {id} --blueprint {json}
make-cli scenarios activate --scenario-id {id}
make-cli scenarios deactivate --scenario-id {id}
make-cli connections create
make-cli connections update --connection-id {id}
make-cli hooks create
make-cli hooks update --hook-id {id}
make-cli data-stores create
make-cli data-stores update --data-store-id {id}

# LEVEL 2 — HIGH RISK
make-cli scenarios run --scenario-id {id}    # executes live — confirm first

# LEVEL 3 — DESTRUCTIVE (irreversible)
make-cli scenarios delete --scenario-id {id}
make-cli hooks delete --hook-id {id}
make-cli connections delete --connection-id {id}
make-cli data-stores delete --data-store-id {id}
make-cli sdk-apps delete --app-name {name} --version {v}
```

---

## Connection Verification

Before using any connection in a new scenario, verify it is working:

```bash
make-cli connections verify --connection-id {id}
```

A broken connection will cause every module using it to fail silently until the first run.
