# Make.com Tool Classification

Reference for `pre-execute` hook. Load before showing any approval gate.

## SAFE — Read-only (no gate)

```
users_me  teams_list  teams_get  organizations_list  organizations_get
scenarios_list  scenarios_get  scenarios_interface
extract_blueprint_components  extract_module_components
executions_list  executions_get  executions_get-detail
connections_list  connections_get  connection-metadata_get
hooks_list  hooks_get  hook-config_get  hook-metadata_get
data-stores_list  data-stores_get  data-store-records_list
data-structures_list  data-structures_get
apps_recommend  app_documentation_get  app-modules_list  app-module_get
validate_blueprint_schema  validate_module_configuration
validate_epoch_configuration  validate_hook_configuration
validate_scenario_interface  validate_scheduling_schema
folders_list  keys_list  keys_get
enums_countries  enums_regions  enums_timezones
credential-requests_list  credential-requests_get
credential-requests_list-app-modules-with-creden
```

## LEVEL 1 — Standard Write (reversible, show plan + get approval)

```
scenarios_create  scenarios_update  scenarios_activate
scenarios_deactivate  scenarios_set-interface
hooks_create  hooks_update
data-stores_create  data-stores_update
data-store-records_create  data-store-records_update  data-store-records_replace
data-structures_create  data-structures_update  data-structures_generate
folders_create  folders_update
teams_create  teams_update
organizations_create  organizations_update
credential-requests_create  credential-requests_create-by-credentials
credential-requests_extend-connection
tools_create  tools_update
```

## LEVEL 2 — HIGH RISK (real-world effects, strong gate, always show)

```
scenarios_run
rpc_execute
```

## LEVEL 3 — DESTRUCTIVE (irreversible, typed confirmation + token required)

```
scenarios_delete  hooks_delete
data-stores_delete  data-store-records_delete  data-structures_delete
folders_delete  keys_delete
teams_delete  organizations_delete
credential-requests_delete  credential-requests_credential-delete
credential-requests_credential-decline
```
