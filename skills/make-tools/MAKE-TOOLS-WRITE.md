# Non-Deterministic Tools (Write / Side Effects)

**These require approval before calling. Log every call via execution-logger skill.**

## MCP Risk Levels

### LEVEL 1 — Standard Write (reversible with effort)

- `scenarios_create` — creates a new inactive scenario
- `scenarios_update` — modifies blueprint (get backup first)
- `scenarios_activate` — makes scenario live
- `scenarios_deactivate` — pauses scenario
- `scenarios_set-interface` — updates I/O interface
- `hooks_create` / `hooks_update`
- `data-stores_create` / `data-stores_update`
- `data-structures_create` / `data-structures_update` / `data-structures_generate`
- `folders_create` / `folders_update`
- `data-store-records_create` / `data-store-records_update` / `data-store-records_replace`
- `credential-requests_create` / `credential-requests_extend-connection`
- `tools_create` / `tools_update`
- `teams_create` / `teams_update`
- `organizations_create` / `organizations_update`

### LEVEL 2 — HIGH RISK (real-world effects, hard to undo)

- `scenarios_run` — executes a live scenario. May send emails, charge money, post data, modify external systems. Always confirm scope and test with safe data first.
- `rpc_execute` — executes a remote procedure with unknown side effects. Use only when explicitly instructed.

### LEVEL 3 — DESTRUCTIVE (irreversible, Make.com has no recycle bin)

- `scenarios_delete`
- `hooks_delete`
- `data-stores_delete`
- `data-store-records_delete`
- `data-structures_delete`
- `folders_delete`
- `keys_delete`
- `credential-requests_delete` / `credential-requests_credential-delete`
- `teams_delete`
- `organizations_delete`

**For LEVEL 3: always get current state first (backup), show user exactly what will be lost, require explicit typed confirmation.**

## CLI — Write Commands

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
