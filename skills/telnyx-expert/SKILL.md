# Telnyx Expert Skill

Load this skill when any conversation involves SMS, voice calls, phone numbers, SIP,
AI assistants, or Telnyx-specific configuration. This is the authoritative reference
for the Telnyx platform within this plugin.

Always also load: `skills/personas/telnyx-consultant.md`

---

## 1. Platform Overview

Telnyx is a cloud communications platform providing:
- **SMS/MMS** — programmatic text messaging
- **Voice** — outbound/inbound calls via Call Control API or TeXML
- **AI Assistants** — voice bots that answer and make phone calls
- **SIP Trunking** — connecting PBX or softphone systems to the PSTN
- **WebRTC** — browser/mobile calling via `@telnyx/webrtc` SDK
- **Phone Numbers** — purchase, port, and manage DID/toll-free numbers
- **Number Intelligence** — lookup line type, CNAM, carrier
- **Cloud Storage** — S3-compatible object storage for recordings and media

**Key concept — Connections:**
A Connection is the routing layer that sits between your phone numbers and your application.
All calls and messages flow through a Connection. There are three connection types:
- **Call Control Connection** — for programmatic voice (Call Control API / TeXML)
- **Fax Connection** — for fax (not covered here)
- **IP/SIP Connection** — for SIP trunking

Numbers are assigned to one Connection. Messages are routed via a Messaging Profile.

---

## 2. SMS and MMS

### Messaging Profile
A Messaging Profile groups phone numbers and defines:
- Inbound webhook URL (where Telnyx POSTs received messages)
- Outbound webhook URL (delivery receipts)
- Enabled regions/features

**Setup flow:**
1. `mcp__telnyx__create_messaging_profile` — create profile with webhook URL
2. `mcp__telnyx__update_phone_number_messaging_settings` — assign number to profile

### Sending SMS
```
mcp__telnyx__send_message
  from: "+15141234567"      ← your Telnyx number
  to:   "+15140000000"      ← recipient
  text: "Hello!"
  messaging_profile_id: "abc-123"
```

### Inbound SMS Webhook Payload
Telnyx POSTs to your webhook URL when a message is received:
```json
{
  "data": {
    "event_type": "message.received",
    "payload": {
      "from": { "phone_number": "+15140000000" },
      "to":   [{ "phone_number": "+15141234567" }],
      "text": "Hello back!",
      "attachments": []
    }
  }
}
```
In Make.com: use a **Custom Webhook** trigger module, then map `{{1.data.payload.text}}`.

### Two-Way SMS Flow in Make.com
```
[Webhook trigger: inbound message]
  → [Set Variable: from = 1.data.payload.from.phone_number]
  → [Set Variable: text = 1.data.payload.text]
  → [Router]
      ├─ Filter: contains(lower(text); "stop") → [Update contact: opted_out=true] → end
      ├─ Filter: contains(lower(text); "help") → [Telnyx: send_message help text]
      └─ Default → [Your business logic] → [Telnyx: send_message reply]
```

### 10DLC and TCPA Compliance (US A2P SMS)
Required before sending bulk SMS to US numbers:

1. **Brand registration** — register your company via Telnyx portal
2. **Campaign registration** — describe your use case (marketing, OTP, notifications)
3. **10DLC approval** — takes 3–5 business days; numbers won't send until approved
4. **STOP keyword** — must handle opt-outs; Telnyx does this automatically for registered campaigns
5. **Consent documentation** — keep records of how each recipient opted in

**CASL (Canada):** Express consent required before sending commercial messages to Canadian numbers.

### MMS Gotchas
- MMS only works on US and Canadian numbers
- Max attachment size: 1.5 MB per message
- Supported types: JPEG, PNG, GIF, MP4 (video), MP3 (audio)
- International MMS not supported — message will fail if `to` is non-US/CA

---

## 3. Voice Calls — Call Control API

### Event Flow
Every outbound call goes through this sequence:
```
make_call → call.initiated → call.ringing → call.answered → [commands] → call.hangup
```

Telnyx POSTs each event to your webhook URL (configured on the Call Control Application).

### Making an Outbound Call
```
mcp__telnyx__make_call
  connection_id: "your-call-control-app-id"
  to:   "+15140000000"
  from: "+15141234567"
  webhook_url: "https://your-server.com/telnyx-webhook"
```

### Call Control Commands (in-call actions)
Use these after `call.answered` webhook fires:

| Tool | Purpose | Key params |
|------|---------|-----------|
| `mcp__telnyx__speak` | Text-to-speech | `call_control_id`, `payload` (text), `voice`, `language` |
| `mcp__telnyx__playback_start` | Play audio file | `call_control_id`, `audio_url` |
| `mcp__telnyx__playback_stop` | Stop audio | `call_control_id` |
| `mcp__telnyx__send_dtmf` | Send keypad tones | `call_control_id`, `digits` |
| `mcp__telnyx__transfer` | Transfer call | `call_control_id`, `to` |
| `mcp__telnyx__hangup` | End call | `call_control_id` |

### IVR DTMF Pattern (in Make.com)
```
[Webhook: call.answered] → [speak: "Press 1 for sales, 2 for support"]
  → [Webhook: call.dtmf.received]
      → [Router]
          ├─ digit = 1 → [transfer to sales queue]
          └─ digit = 2 → [transfer to support queue]
```

### Call Recording
1. Enable recording on the Call Control Application (in portal or via `update_call_control_application`)
2. Recording URL arrives in `call.recording.saved` webhook event
3. **Gotcha:** Recording URL is time-limited (expires in ~24 hours)
4. **Best practice:** On `call.recording.saved`, immediately save the file to cloud storage
   ```
   [Webhook: call.recording.saved] → [HTTP: download recording] → [Telnyx storage / S3: upload]
   ```

### Call Control vs TeXML — When to Use Each

| Use Case | Recommendation |
|----------|---------------|
| Simple IVR, static flow | TeXML (less infrastructure) |
| Dynamic/personalized call flow | Call Control API |
| Real-time decisions based on caller input | Call Control API |
| Quick setup without server | TeXML |
| AI-driven conversations | AI Assistants (see Section 4) |

---

## 4. Voice AI / AI Assistants

Telnyx AI Assistants answer and make calls autonomously using a conversational AI engine.

### Creating an AI Assistant
```
mcp__telnyx__create_assistant
  name: "My AI Receptionist"
  voice: "Telnyx.Paige"          ← or "Telnyx.Marcus"
  language: "en-US"
  system_prompt: "..."            ← the assistant's instructions
  transfer_to: "+15141234567"     ← REQUIRED: human fallback
  end_call_phrases: ["goodbye", "thank you bye", "that's all"]
```

### Available Voice Models
| Voice | Gender | Style |
|-------|--------|-------|
| `Telnyx.Paige` | Female | Professional, warm |
| `Telnyx.Marcus` | Male | Professional, clear |

Third-party voices (ElevenLabs, Azure Neural) available via `voice_settings.voice_provider`.

### System Prompt Template
```
You are [Name], the virtual assistant for [Company Name].
Your role is to [purpose].

You can help callers with:
- [Task 1]
- [Task 2]
- [Task 3]

When a caller asks about something outside your scope, say:
"I'll connect you with a team member who can help with that." then transfer.

Always be professional, brief, and friendly.
End the call by asking: "Is there anything else I can help you with today?"
```

### AI Assistant Design Principles
- **Always set `transfer_to`** — every AI assistant must have a human fallback number
- **Define `end_call_phrases`** — without them, the assistant may not know when to hang up
- **Keep system_prompt under 500 words** — longer prompts increase latency
- **Test with your own number** before deploying — use `mcp__telnyx__start_assistant_call`
- **Handle "agent please"** — train the prompt to recognize escalation requests

### Routing Pattern in Make.com
```
[Webhook: call.initiated] → [Telnyx AI: start_assistant_call with assistant_id]
  → [Webhook: call.ai.gather] ← AI collects info, fires this event with transcript
  → [Your Make.com logic based on what caller said]
  → [Telnyx: speak or transfer]
```

---

## 5. Phone Number Management

### Search and Purchase Flow
```
1. mcp__telnyx__list_available_phone_numbers
     country_code: "CA"
     area_code: "514"
     features: ["sms", "voice"]

2. mcp__telnyx__initiate_phone_number_order
     phone_numbers: ["+15141234567"]
     connection_id: "your-connection-id"     ← assign at purchase time

3. mcp__telnyx__update_phone_number_messaging_settings
     phone_number_id: "..."
     messaging_profile_id: "..."             ← assign to messaging profile for SMS
```

### Monthly Costs (approximate)
- Local DID (US/CA): ~$1–2/month
- Toll-free: ~$2–5/month + usage
- Short code: ~$500–1000/month (requires separate application)

**Always show estimated monthly cost before purchasing.**

### Toll-Free Numbers
- Format: 800, 833, 844, 855, 866, 877, 888 prefixes
- SMS: requires toll-free verification (separate from 10DLC); 3–5 business days
- Higher throughput than local numbers for A2P SMS

### Number Porting
- Porting moves your existing number from another carrier to Telnyx
- Takes 5–10 business days
- Must be initiated through Telnyx portal — no API for porting
- Inform user: calls/SMS will be interrupted during porting window

### Managing Numbers
```
mcp__telnyx__list_phone_numbers          — list all owned numbers
mcp__telnyx__get_phone_number            — get details for one number
mcp__telnyx__update_phone_number         — change connection/config
mcp__telnyx__update_phone_number_messaging_settings  — change messaging profile
```

---

## 6. SIP Trunking

SIP trunking connects a business phone system (PBX, Asterisk, FreePBX, 3CX) to Telnyx for PSTN calls.

### Two Authentication Methods

**IP Authentication (recommended for static IPs):**
1. Create a SIP Connection with IP whitelist
2. No username/password — Telnyx accepts traffic from your IP
3. More secure, simpler to configure

**Credential Authentication:**
1. Create integration secret: `mcp__telnyx__create_integration_secret`
2. Use username/password in your PBX SIP trunk config
3. Use for dynamic IPs or cloud PBX systems

### SIP Endpoint Addresses
```
Outbound proxy:  sip.telnyx.com:5060  (UDP/TCP)
Secure:          sip.telnyx.com:5061  (TLS/SRTP)
```

### Inbound Routing
Assign a phone number to a SIP Connection:
```
mcp__telnyx__update_phone_number
  connection_id: "your-sip-connection-id"
```
Inbound calls ring your PBX via the SIP trunk.

### Caller ID (P-Preferred-Identity)
To present a custom caller ID on outbound calls:
Include `P-Preferred-Identity: <sip:+15141234567@sip.telnyx.com>` in your SIP INVITE.

### SIP Connection Tools
```
mcp__telnyx__get_connection           — read connection config
mcp__telnyx__update_connection        — modify settings
mcp__telnyx__list_connections         — list all connections
mcp__telnyx__create_integration_secret — for credential auth
```

---

## 7. WebRTC

Telnyx WebRTC enables browser and mobile calling using the JavaScript SDK.

### SDK Installation
```bash
npm install @telnyx/webrtc
```

### Basic Click-to-Call Pattern
```javascript
import { TelnyxRTC } from "@telnyx/webrtc";

const client = new TelnyxRTC({
  login: "your-sip-username",
  password: "your-sip-password",
  host: "rtc.telnyx.com"
});

client.on("telnyx.ready", () => {
  const call = client.newCall({ destinationNumber: "+15140000000" });
});

client.connect();
```

### Setup Requirements
1. Create a **Credential Connection** in Telnyx portal
2. Create an **Integration Secret** via `mcp__telnyx__create_integration_secret`
3. Use credentials as SIP username/password in the WebRTC client
4. Assign a phone number to the Credential Connection for caller ID

### Make.com Integration
WebRTC calls generate the same Call Control webhook events as regular calls.
Configure the Credential Connection's webhook URL to point to your Make.com Custom Webhook.
Same `call.answered`, `call.hangup`, recording events apply.

---

## 8. Number Intelligence

Number Intelligence provides carrier lookup data before calling or messaging.

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

## 9. Cloud Storage

Telnyx provides S3-compatible cloud storage — useful for persisting call recordings and media.

### Bucket and Object Tools
```
mcp__telnyx__cloud_storage_list_buckets      — list buckets
mcp__telnyx__cloud_storage_create_bucket     — create bucket
  name: "my-recordings"
  region: "us-east-1"

mcp__telnyx__cloud_storage_upload_file       — upload file
  bucket: "my-recordings"
  key: "calls/2026-06-12-call-001.mp3"
  file_path: "/tmp/recording.mp3"

mcp__telnyx__cloud_storage_list_objects      — list objects in bucket
mcp__telnyx__cloud_storage_download_file     — download object
mcp__telnyx__cloud_storage_delete_object     — delete object
mcp__telnyx__cloud_storage_get_bucket_location — get bucket region info

mcp__telnyx__list_embedded_buckets           — list buckets accessible to AI assistant
mcp__telnyx__embed_url                       — create a pre-signed URL for private object access
```

### Recording Persistence Pattern
Call recordings expire quickly. Persist them immediately:
```
[Webhook: call.recording.saved]
  → [HTTP: GET recording_url (download binary)]
  → [cloud_storage_upload_file: bucket=recordings, key=calls/{{formatDate(now;"YYYY-MM-DD")}}/{{1.call_control_id}}.mp3]
  → [Data Store: save record {call_id, storage_key, duration, caller, timestamp}]
```

---

## 10. Observability and Debugging

### Tools
```
mcp__telnyx__get_webhook_events        — retrieve recent webhook events for debugging
mcp__claude_ai_Telnyx__open_voice_monitor    — open voice monitor portal (live call view)
mcp__claude_ai_Telnyx__open_usage_cost_explorer  — open cost explorer portal
```

### Debugging SMS Delivery
1. `mcp__telnyx__get_message` — get status of a specific message by ID
2. Check: `status` field — `received`, `sent`, `delivered`, `delivery_failed`
3. For failures: check `errors` array in message response for carrier rejection codes

### Debugging Voice Calls
1. `mcp__telnyx__get_webhook_events` — see all events for a call
2. `mcp__claude_ai_Telnyx__open_voice_monitor` — real-time call state
3. Check: Is call_control_id correct? Webhook reachable from internet? TLS valid?

### Common Issues
| Problem | Check |
|---------|-------|
| SMS not delivered | Is number on a Messaging Profile? Is 10DLC approved? |
| Webhook not received | Is URL publicly accessible? Check Telnyx webhook logs in portal |
| Call hangs up immediately | Is connection active? Check webhook URL responds with HTTP 200 |
| AI assistant silent | Check system_prompt length; verify voice model name exact spelling |
| Recording URL expired | Always save within 24 hours — set up automatic persistence |

---

## 11. Dynamic API Access Pattern

For any Telnyx capability not covered by named MCP tools:

```
Step 1: mcp__claude_ai_Telnyx__list_api_endpoints
  → Review available endpoints by category

Step 2: mcp__claude_ai_Telnyx__get_api_endpoint_schema
  endpoint: "/v2/phone_numbers/{id}/actions/enable_emergency_calling"
  → Understand required parameters

Step 3: mcp__claude_ai_Telnyx__invoke_api_endpoint
  method: "POST"
  path: "/v2/phone_numbers/123/actions/enable_emergency_calling"
  body: { ... }
```

Use this pattern for:
- Emergency calling setup
- Number porting status checks
- Fax configuration
- Sub-accounts and billing
- Any endpoint added to Telnyx API after this skill was written

---

## 12. Telnyx CLI — Local Development

The Telnyx CLI enables local testing without a public server.

### Installation
```bash
# macOS
brew tap telnyx/telnyx && brew install telnyx-cli

# Or npm
npm install -g @telnyx/cli
```

### Authentication
```bash
telnyx login
# Enter your API key when prompted
```

### Local Webhook Tunnel
Forward Telnyx webhooks to your local machine:
```bash
telnyx webhook listen --port 3000
```
This gives you a public URL like `https://abc123.webhooks.telnyx.com`.
Use that URL in your Call Control Application or Messaging Profile webhook config.

### Common CLI Commands
```bash
# Test outbound SMS
telnyx messages send --from +15141234567 --to +15140000000 --text "Hello from CLI"

# List phone numbers
telnyx phone-numbers list

# Get phone number details
telnyx phone-numbers get +15141234567

# List messaging profiles
telnyx messaging-profiles list

# View recent calls
telnyx calls list

# Run API call
telnyx api get /v2/phone_numbers
```

### Testing Workflow
1. `telnyx webhook listen --port 3000` — start local tunnel
2. Update webhook URL in Call Control App or Messaging Profile to tunnel URL
3. Make a test call or send a test SMS to your Telnyx number
4. Watch webhook events arrive in your local server logs
5. Iterate on your Make.com scenario or code without deploying to a server

---

## 13. Approval Gate Classification

All Telnyx MCP tools are classified into tiers. The pre-execute hook enforces these gates.

### SAFE — Read-only, no cost, no side effects (23 tools)
No approval required:
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
```

### LEVEL 1 — Reversible writes, no real-world effect (10 tools)
Require plan + "approve" confirmation. Can be undone:
```
create_messaging_profile      update_messaging_profile
create_call_control_application
update_connection
create_integration_secret     delete_integration_secret
cloud_storage_create_bucket   cloud_storage_upload_file   cloud_storage_delete_object
update_phone_number_messaging_settings
```

### LEVEL 2 — Real-world effect, incurs cost or sends to real recipients (10 tools)
Require explicit gate showing recipient/number, estimated cost, and "send it" confirmation:
```
send_message          ← sends real SMS to recipient
make_call             ← initiates live phone call (per-minute billing starts)
start_assistant_call  ← starts live AI call
speak                 ← plays TTS on live call
playback_start        ← plays audio on live call
transfer              ← transfers live call
send_dtmf             ← sends tones on live call
playback_stop         ← stops audio on live call
update_phone_number   ← changes routing on active number
update_assistant      ← modifies live assistant behavior
```

**Level 2 gate format:**
```
TELNYX LEVEL 2 — REAL-WORLD ACTION
-----------------------------------
Action:       Send SMS
To:           +15140000000 (recipient's number)
From:         +15141234567 (your Telnyx number)
Message:      "Hello, your order is ready."
Estimated cost: ~$0.004 per message

This will send a real SMS. Type "send it" to confirm.
```

### LEVEL 3 — Destructive or irreversible (3 tools)
Require explicit acknowledgment of irreversibility + "send it" confirmation:
```
mcp__telnyx__mcp_telnyx_delete_assistant   ← permanently deletes AI assistant
hangup                                      ← ends live call (cannot be undone)
initiate_phone_number_order                 ← purchases number (billing begins, may be non-refundable)
```

**Level 3 gate format:**
```
TELNYX LEVEL 3 — DESTRUCTIVE ACTION
-------------------------------------
Action:    Purchase phone number
Number:    +15141234567
Cost:      ~$1.00/month ongoing (billing starts immediately)
Warning:   Phone number purchases may be non-refundable.

Type "send it" to confirm this irreversible action.
```
