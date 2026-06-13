# /voice Command

Activates the Telnyx voice specialist flow for phone calls, IVR, AI receptionist, SIP trunking, and call recording.

## Triggers

- `/voice` — voice readiness check + flow menu
- `/voice ai` — set up AI receptionist
- `/voice outbound` — set up outbound calling
- `/voice inbound` — set up inbound call routing
- `/voice ivr` — build an IVR phone menu
- `/voice sip` — set up SIP trunking
- `/voice recording` — set up call recording

## Agent: telnyx-agent

## Flow

### Phase 0 — Voice Readiness Check
Run parallel reads:
- `list_phone_numbers` — numbers with voice feature
- `list_call_control_applications` — voice routing apps
- `list_connections` — SIP/call control connections
- `list_assistants` — existing AI assistants

Display readiness:
```
VOICE READINESS CHECK
──────────────────────
Voice-capable numbers:    [count] ([list])
Call control applications: [count]
Connections:              [count]
AI assistants:            [count]

Status: [Ready / Partial setup / Not configured]
```

### Phase 1 — Intent Discovery
Ask what the user wants. Route to one of 6 flows:

---

**Flow A — AI Receptionist:**
Fully automated AI that answers calls and handles common requests.

Steps:
1. Ask for business name, purpose, and 2–3 things callers typically need
2. Ask for human fallback number (required — no AI assistant deploys without it)
3. Draft system prompt using template from telnyx-expert skill Section 4
4. Show prompt to user for review — iterate until approved
5. Level 1 gate: create assistant via `create_assistant`
6. Assign Telnyx number to Call Control Application pointing to assistant
7. Level 2 gate: test call via `start_assistant_call` to user's own number
8. Iterate on prompt based on test results
9. Log and document

---

**Flow B — Outbound Calling:**
Make programmatic outbound calls from Make.com scenarios.

Steps:
1. Confirm Call Control Application exists; create if not
2. Show Make.com webhook module setup (receive call events)
3. Walk through `make_call` → `call.answered` → `speak` pattern
4. Level 2 gate: test call to user's own number
5. Confirm audio plays correctly

---

**Flow C — Inbound Call Routing:**
Route incoming calls to the right destination.

Steps:
1. Confirm number is assigned to a Call Control Application
2. Ask for routing logic (always transfer? IVR? AI first?)
3. Design routing scenario in Make.com
4. Set webhook URL on Call Control Application
5. Test: call the Telnyx number, confirm routing

---

**Flow D — IVR Phone Menu:**
Press 1 for sales, 2 for support — interactive voice menus.

Sub-choice: TeXML (simpler, static) or Call Control API (dynamic, programmable)

TeXML path:
1. Draft TeXML script based on menu options user describes
2. Host TeXML at a URL (Cloudflare Worker or Make.com webhook response)
3. Set TeXML URL on Call Control Application
4. Test: call the number, confirm menu plays

Call Control path:
1. Design Make.com scenario with webhook trigger
2. `speak` prompt → listen for DTMF → `Router` by digit → branch logic
3. Set webhook URL on Call Control Application
4. Test: call the number, press each digit

---

**Flow E — SIP Trunking:**
Connect an office PBX or softphone system to Telnyx.

Steps:
1. Ask: IP auth or credential auth?
2. IP auth: capture static IP of PBX; create IP Connection with IP whitelist
3. Credential auth: `create_integration_secret`; provide username/password to user
4. SIP endpoint: `sip.telnyx.com:5060` (or 5061 for TLS)
5. Assign phone number to SIP Connection
6. Test: make an outbound call from PBX

---

**Flow F — Call Recording:**
Record all calls or specific calls.

Steps:
1. Enable recording on Call Control Application (via portal or `create_call_control_application` with recording enabled)
2. Set up `call.recording.saved` webhook in Make.com
3. Build automatic download + storage pipeline (cloud_storage_upload_file)
4. Remind user about two-party consent disclosure
5. Test: make a test call, confirm recording appears in storage

---

### Phase 2 — Plan with Costs
Show estimated cost for any chargeable action.
Voice costs approximate:
- Inbound call: ~$0.004/min
- Outbound call: ~$0.005–0.02/min depending on destination
- AI assistant: per-minute (check telnyx.com/pricing for current rates)
- Phone number: ~$1–2/month

### Phase 3 — Execute with Approval Gates
Apply Level 1/2/3 gates per telnyx-expert skill Section 13.
Narrate each MCP call.

### Phase 4 — Test
Always test with the user's own phone number before going live.
For AI assistants: call the number yourself and verify the conversation flow.

### Phase 5 — Log
Write to `.make/logs/telnyx-{{formatDate(now; "YYYY-MM-DD")}}.md`
