# Telnyx Expert — Number Intelligence and Cloud Storage

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Number Intelligence

Provides carrier lookup data before calling or messaging.

### Lookup Call

```
Use: mcp__claude_ai_Telnyx__invoke_api_endpoint
  endpoint: GET /v2/number_lookup/{phone_number}
  params: { type: "carrier" }
```

Or use `mcp__claude_ai_Telnyx__open_number_intelligence` to open the portal UI.

### Response Fields

| Field | Meaning |
|-------|---------|
| `line_type` | `mobile`, `landline`, `voip`, `toll-free` |
| `carrier` | Carrier name |
| `cnam` | Caller name (CNAM) if available |
| `country_code` | ISO 2-letter country code |
| `ported` | Whether number was ported |

### Use Cases

- Pre-screen phone list: skip landlines before SMS campaign
- Route mobile vs landline callers differently
- Detect VOIP numbers that may indicate spam

### Cost Note

Each lookup is charged per-query. Use Make.com Data Store to cache results:
```
[Check Data Store for phone number]
  ├─ Found → use cached result
  └─ Not found → [Number Intelligence lookup] → [Store result in Data Store]
```

---

## Cloud Storage

Telnyx provides S3-compatible cloud storage — useful for persisting call recordings
and media.

### Bucket and Object Tools

```
mcp__telnyx__cloud_storage_list_buckets      — list buckets
mcp__telnyx__cloud_storage_create_bucket     — create bucket (LEVEL 1)
  name: "my-recordings"
  region: "us-east-1"

mcp__telnyx__cloud_storage_upload_file       — upload file (LEVEL 1)
  bucket: "my-recordings"
  key: "calls/2026-06-12-call-001.mp3"
  file_path: "/tmp/recording.mp3"

mcp__telnyx__cloud_storage_list_objects      — list objects in bucket
mcp__telnyx__cloud_storage_download_file     — download object
mcp__telnyx__cloud_storage_delete_object     — delete object (LEVEL 1)
mcp__telnyx__cloud_storage_get_bucket_location — get bucket region info

mcp__telnyx__list_embedded_buckets           — list buckets accessible to AI assistant
mcp__telnyx__embed_url                       — create a pre-signed URL for private object
```

### Recording Persistence Pattern

Call recordings expire quickly. Persist them immediately:
```
[Webhook: call.recording.saved]
  → [HTTP: GET recording_url (download binary)]
  → [cloud_storage_upload_file:
       bucket=recordings,
       key=calls/{{formatDate(now;"YYYY-MM-DD")}}/{{1.call_control_id}}.mp3]
  → [Data Store: save record {call_id, storage_key, duration, caller, timestamp}]
```
