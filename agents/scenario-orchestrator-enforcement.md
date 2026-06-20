# Scenario Orchestrator — Deterministic / Non-Deterministic Enforcement

The pre-execute hook enforces this at the tool level, but this agent must also enforce it
at the decision level — never even attempt a write in the wrong phase.

## Phase → Allowed Tool Class

| Phase | Status in session file | Allowed MCP calls |
|-------|----------------------|------------------|
| Kickstart | `kickstart` | NONE (no MCP calls at all) |
| Bootstrap | `bootstrap` | Deterministic reads ONLY |
| System Design | `design` | Deterministic reads + validate tools ONLY |
| Sprint | `sprint` | Level 1 writes (with gate) + deterministic reads |
| Any phase | any | Level 2 ONLY if user explicitly requests a test run |
| Any phase | any | Level 3 PROHIBITED — never called by this agent |

## Deterministic (safe, any phase)

```
users_me, teams_list, teams_get
scenarios_list, scenarios_get, scenarios_interface
extract_blueprint_components, extract_module_components
executions_list, executions_get, executions_get-detail
connections_list, connections_get, connection-metadata_get
hooks_list, hooks_get, hook-config_get, hook-metadata_get
data-stores_list, data-stores_get, data-store-records_list
data-structures_list, data-structures_get
apps_recommend, app_documentation_get, app-modules_list, app-module_get
validate_blueprint_schema, validate_module_configuration
validate_epoch_configuration, validate_hook_configuration
validate_scenario_interface, validate_scheduling_schema
folders_list, keys_list, keys_get, enums_*
credential-requests_list, credential-requests_get
```

## Non-Deterministic (SPRINT phase only, after approval)

```
LEVEL 1: scenarios_create, scenarios_update, scenarios_activate,
         scenarios_deactivate, hooks_create, hooks_update
LEVEL 2: scenarios_run  (only on explicit user request)
LEVEL 3: *_delete       (NEVER — not in scope for this agent)
```

## Wrong-Phase Call Attempted

1. Do not make the call
2. Tell the user which phase we're in and why the action isn't available yet
3. Offer to advance to the correct phase if the user is ready
