# Deterministic Tools (Read-Only, Safe)

These can be called freely without approval. They read state, they do not change it.

## MCP — Scenarios

| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__scenarios_list` | All scenarios for a team with status, schedule, last run |
| `mcp__claude_ai_Make__scenarios_get` | Full blueprint + metadata for one scenario |
| `mcp__claude_ai_Make__scenarios_interface` | Input/output interface definition for a scenario |
| `mcp__claude_ai_Make__extract_blueprint_components` | Parses a blueprint into structured module list |
| `mcp__claude_ai_Make__extract_module_components` | Parses a single module's configuration |
| `mcp__claude_ai_Make__executions_list` | Run history for a scenario |
| `mcp__claude_ai_Make__executions_get` | Summary of one execution |
| `mcp__claude_ai_Make__executions_get-detail` | Full execution log with module-by-module results |

## MCP — Connections, Webhooks, Data

| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__connections_list` | All authenticated connections for a team |
| `mcp__claude_ai_Make__connections_get` | Details of one connection |
| `mcp__claude_ai_Make__connection-metadata_get` | Schema and capabilities of a connection type |
| `mcp__claude_ai_Make__hooks_list` | All webhooks and mailhooks |
| `mcp__claude_ai_Make__hooks_get` | One webhook's details and URL |
| `mcp__claude_ai_Make__hook-config_get` | Full config schema for a hook type |
| `mcp__claude_ai_Make__hook-metadata_get` | Metadata and capabilities |
| `mcp__claude_ai_Make__data-stores_list` | All data stores |
| `mcp__claude_ai_Make__data-stores_get` | One data store's config |
| `mcp__claude_ai_Make__data-store-records_list` | Records in a data store |
| `mcp__claude_ai_Make__data-structures_list` | All data structures (schemas) |
| `mcp__claude_ai_Make__data-structures_get` | One data structure's schema |

## MCP — Discovery, Validation, Account

| Tool | What it returns |
|------|----------------|
| `mcp__claude_ai_Make__apps_recommend` | Suggests Make.com apps for a use case |
| `mcp__claude_ai_Make__app_documentation_get` | Full docs for an app |
| `mcp__claude_ai_Make__app-modules_list` | All modules for an app |
| `mcp__claude_ai_Make__app-module_get` | One module's full schema and config |
| `mcp__claude_ai_Make__validate_blueprint_schema` | Full scenario blueprint JSON |
| `mcp__claude_ai_Make__validate_module_configuration` | One module's config |
| `mcp__claude_ai_Make__validate_epoch_configuration` | Scheduling configuration |
| `mcp__claude_ai_Make__validate_hook_configuration` | Webhook configuration |
| `mcp__claude_ai_Make__validate_scenario_interface` | Scenario input/output interface |
| `mcp__claude_ai_Make__validate_scheduling_schema` | Schedule definition |
| `mcp__claude_ai_Make__users_me` | Current authenticated user |
| `mcp__claude_ai_Make__teams_list` / `teams_get` | Teams for the org |
| `mcp__claude_ai_Make__organizations_list` / `organizations_get` | Organizations |
| `mcp__claude_ai_Make__folders_list` | Scenario folders |
| `mcp__claude_ai_Make__enums_countries` / `regions` / `timezones` | Reference data |

## CLI — Read-Only Commands

```bash
make-cli whoami
make-cli scenarios list --team-id {id}
make-cli scenarios get --scenario-id {id}
make-cli scenarios interface --scenario-id {id}
make-cli executions list --scenario-id {id}
make-cli executions get --execution-id {id}
make-cli executions get-detail --execution-id {id}
make-cli connections list --team-id {id}
make-cli connections get --connection-id {id}
make-cli hooks list --team-id {id}
make-cli hooks get --hook-id {id}
make-cli data-stores list --team-id {id}
make-cli data-stores get --data-store-id {id}
make-cli data-store-records list --data-store-id {id}
make-cli sdk-apps list
make-cli sdk-apps get --app-name {name} --version {v}
make-cli enums countries
make-cli enums timezones
```
