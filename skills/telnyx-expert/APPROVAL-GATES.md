# Telnyx Expert — Approval Gates

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

Every Telnyx MCP tool falls into one of four risk tiers.
Always check the tier before calling a tool.

---

## SAFE — No approval required

Read-only, no side effects:

```
mcp__telnyx__list_phone_numbers
mcp__telnyx__get_phone_number
mcp__telnyx__list_messaging_profiles
mcp__telnyx__get_messaging_profile
mcp__telnyx__list_assistants
mcp__telnyx__get_assistant
mcp__telnyx__get_assistant_texml
mcp__telnyx__list_connections
mcp__telnyx__get_connection
mcp__telnyx__get_message
mcp__telnyx__get_webhook_events
mcp__telnyx__list_call_control_applications
mcp__telnyx__list_integration_secrets
mcp__telnyx__cloud_storage_list_buckets
mcp__telnyx__cloud_storage_list_objects
mcp__telnyx__cloud_storage_get_bucket_location
mcp__telnyx__list_embedded_buckets
mcp__claude_ai_Telnyx__list_api_endpoints
mcp__claude_ai_Telnyx__get_api_endpoint_schema
mcp__claude_ai_Telnyx__open_voice_monitor
mcp__claude_ai_Telnyx__open_number_intelligence
mcp__claude_ai_Telnyx__open_usage_cost_explorer
```

---

## LEVEL 1 — Show plan, wait for "yes"

Create or modify non-destructive resources. Reversible with effort.

```
mcp__telnyx__create_messaging_profile
mcp__telnyx__update_messaging_profile
mcp__telnyx__update_phone_number_messaging_settings
mcp__telnyx__create_integration_secret
mcp__telnyx__update_connection
mcp__telnyx__create_call_control_application
mcp__telnyx__cloud_storage_create_bucket
mcp__telnyx__cloud_storage_upload_file
mcp__telnyx__cloud_storage_delete_object
mcp__telnyx__create_assistant
```

---

## LEVEL 2 — Show cost + impact, wait for "approve"

Modifies live, in-use resources. Partial rollback possible.

```
mcp__telnyx__update_phone_number              ← changes routing on live number
mcp__telnyx__update_assistant                 ← changes live AI assistant behavior
mcp__telnyx__update_call_control_application  ← changes live call routing
mcp__telnyx__make_call                        ← initiates real call, incurs cost
mcp__telnyx__send_message                     ← sends real SMS, incurs cost
mcp__claude_ai_Telnyx__invoke_api_endpoint    ← when POST/PATCH/PUT
```

---

## LEVEL 3 — Destructive warning block required

Irreversible. Show `⛔ DESTRUCTIVE ACTION` block (see `destructive-ops.md`) before proceeding.

```
mcp__telnyx__initiate_phone_number_order      ← purchase (billed monthly, non-refundable)
mcp__telnyx__mcp_telnyx_delete_assistant      ← permanent delete
mcp__telnyx__delete_integration_secret        ← breaks auth for all users of secret
mcp__claude_ai_Telnyx__invoke_api_endpoint    ← when DELETE
```

---

## Approval Format (LEVEL 2 / 3)

```
TELNYX PLAN
-----------
Action:     [what will happen]
Tool:       [exact MCP tool name]
Target:     [number / assistant / connection]
Cost:       [per-call / per-message / monthly]
Reversible: YES / NO / MAYBE

Type "approve" to proceed.
```
