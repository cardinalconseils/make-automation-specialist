# Pre-Execute: Telnyx Classification & Gates

Same gate system as Make.com. Load alongside `pre-execute-gate-formats.md`.

---

## SAFE — Read-only, no cost (no gate)

```
list_phone_numbers          get_phone_number
list_messaging_profiles     get_messaging_profile
list_connections            get_connection
list_call_control_applications  get_call_control_application
list_assistants             get_assistant             get_assistant_texml
list_integration_secrets    get_message
get_webhook_events
cloud_storage_list_buckets  cloud_storage_list_objects
cloud_storage_get_bucket_location  cloud_storage_download_file
list_embedded_buckets       list_available_phone_numbers
open_voice_monitor          open_usage_cost_explorer
open_number_intelligence    list_api_endpoints  get_api_endpoint_schema
```

---

## LEVEL 1 — Reversible writes (standard approval gate)

```
create_messaging_profile      update_messaging_profile
create_call_control_application
update_connection
create_integration_secret     delete_integration_secret
cloud_storage_create_bucket   cloud_storage_upload_file
cloud_storage_delete_object   update_phone_number_messaging_settings
```

---

## LEVEL 2 — Real-world effects (always show, requires "send it")

```
send_message          make_call             start_assistant_call
speak                 playback_start        playback_stop
transfer              send_dtmf
update_phone_number   update_assistant
```

Gate:
```
TELNYX — REAL-WORLD ACTION
─────────────────────────────────────
Action:        {e.g., Send SMS / Make Call}
To:            {recipient phone number}
From:          {your Telnyx number}
Content:       {message text or call purpose}
Estimated cost: ~{$X.XXX per message/minute}

Type "send it" to confirm.
─────────────────────────────────────
```

Valid ONLY: "send it"

---

## LEVEL 3 — Destructive / irreversible

```
mcp__telnyx__mcp_telnyx_delete_assistant  — deletes AI assistant permanently
hangup                                     — ends live call (irreversible)
initiate_phone_number_order               — purchases number (billing begins)
```

Gate:
```
TELNYX — DESTRUCTIVE / IRREVERSIBLE
──────────────────────────────────────
Action:   {action description}
Warning:  {what makes this irreversible}
Cost:     {monthly/one-time charge if applicable}

Type "send it" to confirm this irreversible action.
──────────────────────────────────────
```

Write approval token after confirmation. See `approval-token-protocol.md`.
