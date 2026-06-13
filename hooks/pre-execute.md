# Hook: pre-execute

**Event:** before.mcp.write
**Trigger:** Fires before any Make.com MCP call — classifies it and gates write calls

## Purpose

Enforce the deterministic / non-deterministic framework across ALL agents, skills,
commands, and the orchestrator. No write operation proceeds without the correct
approval gate. Read-only calls pass through silently.

---

## Step 1 — Classify the Incoming Tool Call

Look up the tool name being called and assign its risk class.

### SAFE — Deterministic (no gate, proceed immediately)

These are read-only. Call freely. Do not show approval gates for these.

```
mcp__claude_ai_Make__users_me
mcp__claude_ai_Make__teams_list
mcp__claude_ai_Make__teams_get
mcp__claude_ai_Make__organizations_list
mcp__claude_ai_Make__organizations_get
mcp__claude_ai_Make__scenarios_list
mcp__claude_ai_Make__scenarios_get
mcp__claude_ai_Make__scenarios_interface
mcp__claude_ai_Make__extract_blueprint_components
mcp__claude_ai_Make__extract_module_components
mcp__claude_ai_Make__executions_list
mcp__claude_ai_Make__executions_get
mcp__claude_ai_Make__executions_get-detail
mcp__claude_ai_Make__connections_list
mcp__claude_ai_Make__connections_get
mcp__claude_ai_Make__connection-metadata_get
mcp__claude_ai_Make__hooks_list
mcp__claude_ai_Make__hooks_get
mcp__claude_ai_Make__hook-config_get
mcp__claude_ai_Make__hook-metadata_get
mcp__claude_ai_Make__data-stores_list
mcp__claude_ai_Make__data-stores_get
mcp__claude_ai_Make__data-store-records_list
mcp__claude_ai_Make__data-structures_list
mcp__claude_ai_Make__data-structures_get
mcp__claude_ai_Make__apps_recommend
mcp__claude_ai_Make__app_documentation_get
mcp__claude_ai_Make__app-modules_list
mcp__claude_ai_Make__app-module_get
mcp__claude_ai_Make__validate_blueprint_schema
mcp__claude_ai_Make__validate_module_configuration
mcp__claude_ai_Make__validate_epoch_configuration
mcp__claude_ai_Make__validate_hook_configuration
mcp__claude_ai_Make__validate_scenario_interface
mcp__claude_ai_Make__validate_scheduling_schema
mcp__claude_ai_Make__folders_list
mcp__claude_ai_Make__keys_list
mcp__claude_ai_Make__keys_get
mcp__claude_ai_Make__enums_countries
mcp__claude_ai_Make__enums_regions
mcp__claude_ai_Make__enums_timezones
mcp__claude_ai_Make__credential-requests_list
mcp__claude_ai_Make__credential-requests_get
mcp__claude_ai_Make__credential-requests_list-app-modules-with-creden
```

### LEVEL 1 — Standard Write (reversible, show plan + get approval)

```
mcp__claude_ai_Make__scenarios_create
mcp__claude_ai_Make__scenarios_update
mcp__claude_ai_Make__scenarios_activate
mcp__claude_ai_Make__scenarios_deactivate
mcp__claude_ai_Make__scenarios_set-interface
mcp__claude_ai_Make__hooks_create
mcp__claude_ai_Make__hooks_update
mcp__claude_ai_Make__data-stores_create
mcp__claude_ai_Make__data-stores_update
mcp__claude_ai_Make__data-store-records_create
mcp__claude_ai_Make__data-store-records_update
mcp__claude_ai_Make__data-store-records_replace
mcp__claude_ai_Make__data-structures_create
mcp__claude_ai_Make__data-structures_update
mcp__claude_ai_Make__data-structures_generate
mcp__claude_ai_Make__folders_create
mcp__claude_ai_Make__folders_update
mcp__claude_ai_Make__teams_create
mcp__claude_ai_Make__teams_update
mcp__claude_ai_Make__organizations_create
mcp__claude_ai_Make__organizations_update
mcp__claude_ai_Make__credential-requests_create
mcp__claude_ai_Make__credential-requests_create-by-credentials
mcp__claude_ai_Make__credential-requests_extend-connection
mcp__claude_ai_Make__tools_create
mcp__claude_ai_Make__tools_update
```

### LEVEL 2 — HIGH RISK (real-world effects, stronger gate)

```
mcp__claude_ai_Make__scenarios_run
mcp__claude_ai_Make__rpc_execute
```

### LEVEL 3 — DESTRUCTIVE (irreversible, typed confirmation required)

```
mcp__claude_ai_Make__scenarios_delete
mcp__claude_ai_Make__hooks_delete
mcp__claude_ai_Make__data-stores_delete
mcp__claude_ai_Make__data-store-records_delete
mcp__claude_ai_Make__data-structures_delete
mcp__claude_ai_Make__folders_delete
mcp__claude_ai_Make__keys_delete
mcp__claude_ai_Make__teams_delete
mcp__claude_ai_Make__organizations_delete
mcp__claude_ai_Make__credential-requests_delete
mcp__claude_ai_Make__credential-requests_credential-delete
mcp__claude_ai_Make__credential-requests_credential-decline
```

---

## Step 2 — Phase Context Check (for /factory sessions)

If a `/factory` session is active (`.make/factory/current-session.json` exists):

Check `current-session.json` → `status` field:
- `status: "kickstart"` → BLOCK all Level 1/2/3 calls with: "We're still in the discovery phase — no changes can be made yet."
- `status: "bootstrap"` → BLOCK all Level 1/2/3 calls with: "We're still mapping the workspace — no changes yet."
- `status: "design"` → BLOCK all Level 1/2/3 calls with: "We're in the design phase — waiting for your approval before building."
- `status: "sprint"` → ALLOW Level 1 calls (with gate), ALLOW Level 2 with HIGH RISK gate, BLOCK Level 3 (require explicit user request outside of sprint flow)
- `status: "complete"` → Normal operation (standard gates apply)

If no factory session is active: skip phase check and apply standard gates below.

---

## Step 3 — Apply the Correct Approval Gate

### LEVEL 1 Gate

Check session memory: was this specific action already approved in the current turn?
- If yes (approval marker exists for this exact action + target): proceed
- If no: show gate

```
APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What I'm about to do: {plain-language description}
Target: {resource name}
Type: {create / update / activate / deactivate}
Risk: Low — reversible

{Summary of changes if create or update}

Type "approve" to proceed, or tell me what to change.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Valid approval phrases: "approve", "yes", "go ahead", "do it", "confirmed", "ok", "proceed", "build all", "run it".

### LEVEL 2 Gate (HIGH RISK)

Always show, even if batch approval was given:

```
HIGH-RISK ACTION — REVIEW CAREFULLY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
I am about to EXECUTE a live scenario. This may:
• Send real emails or messages to real people
• Write or delete real data in external systems
• Trigger charges or payments
• Post to social media or external platforms

Scenario: {name}
Last run: {date or "never"}
Estimated operations this run: ~{n}

Have you tested this with safe/test data first?

Type "run it" to execute, or tell me to stop.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Valid approval phrases ONLY: "run it", "execute it", "yes run it".

### LEVEL 3 Gate (DESTRUCTIVE)

Always show. Never skip for any reason. Batch approval does NOT cover Level 3.

```
DESTRUCTIVE ACTION — CANNOT BE UNDONE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You are about to permanently delete:

  {Resource type}: {name}
  Created: {date}
  {Relevant stats}

Make.com has no recycle bin. This is permanent.

Type exactly: DELETE {resource name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Only proceed if the user types the exact phrase. Any typo = re-show the gate.

---

## Step 4 — Log the Gate Outcome

Write to `.make/logs/approvals.md` regardless of outcome:

```markdown
## {timestamp}
Tool: {tool name}
Risk level: {LEVEL 1 / LEVEL 2 / LEVEL 3}
Resource: {name or id}
Agent/command: {which agent or command requested this}
Factory phase: {kickstart/bootstrap/design/sprint/none}
Outcome: {approved | refused | blocked-wrong-phase | cancelled}
```

---

---

## Telnyx MCP Tool Classification

The same gate system applies to all `mcp__telnyx__*` tools.

### SAFE — Read-only, no cost (no gate)
```
list_phone_numbers          get_phone_number
list_messaging_profiles     get_messaging_profile
list_connections            get_connection
list_call_control_applications  get_call_control_application
list_assistants             get_assistant             get_assistant_texml
list_integration_secrets    get_message
get_webhook_events
cloud_storage_list_buckets  cloud_storage_list_objects  cloud_storage_get_bucket_location
cloud_storage_download_file list_embedded_buckets
list_available_phone_numbers
open_voice_monitor          open_usage_cost_explorer    open_number_intelligence
list_api_endpoints          get_api_endpoint_schema
```

### LEVEL 1 — Reversible writes (standard approval gate)
```
create_messaging_profile      update_messaging_profile
create_call_control_application
update_connection
create_integration_secret     delete_integration_secret
cloud_storage_create_bucket   cloud_storage_upload_file   cloud_storage_delete_object
update_phone_number_messaging_settings
```

### LEVEL 2 — Real-world effect: sends real SMS or makes live calls (strong gate)
Always show recipient/number, estimated cost, and require "send it":

```
TELNYX LEVEL 2 — REAL-WORLD ACTION
─────────────────────────────────────
Action:        {e.g., Send SMS}
To:            {recipient phone number}
From:          {your Telnyx number}
Message/Call:  {message text or call purpose}
Estimated cost: ~{$X.XXX per message/minute}

This will {send a real SMS / initiate a live phone call}.
Type "send it" to confirm.
─────────────────────────────────────
```

Tools in this tier:
```
send_message          make_call             start_assistant_call
speak                 playback_start        playback_stop
transfer              send_dtmf
update_phone_number   update_assistant
```

Valid approval phrase: **"send it"** only.

### LEVEL 3 — Destructive or irreversible (highest gate)
```
mcp__telnyx__mcp_telnyx_delete_assistant   — permanently deletes AI assistant
hangup                                      — ends live call (irreversible)
initiate_phone_number_order                 — purchases number (billing starts, may be non-refundable)
```

Gate format:
```
TELNYX LEVEL 3 — DESTRUCTIVE ACTION
──────────────────────────────────────
Action:   {action description}
Warning:  {what makes this irreversible}
Cost:     {monthly/one-time charge if applicable}

Type "send it" to confirm this irreversible action.
──────────────────────────────────────
```

---

## Enforcement Scope

This hook applies to ALL agents, skills, and commands:
- `automation-specialist`
- `scenario-orchestrator`
- `scenario-auditor`
- `automation-planner`
- `scenario-reporter`
- `telnyx-agent`
- All skills (plan-builder, sprint-runner, kickstart-intake, telnyx-expert, etc.)
- All commands (/make, /factory, /audit, /fix, /plan, /telnyx, /sms, /voice)

No agent or skill can bypass this hook. No exceptions.
