---
description: Activate Telnyx voice specialist for phone calls, IVR, AI receptionist, and SIP trunking
allowed-tools: Agent
---

# /voice Command

Activates the Telnyx voice specialist flow for phone calls, IVR, AI receptionist,
SIP trunking, and call recording.

## Triggers

- `/voice` — voice readiness check + flow menu
- `/voice ai` — set up AI receptionist
- `/voice outbound` — set up outbound calling
- `/voice inbound` — set up inbound call routing
- `/voice ivr` — build an IVR phone menu
- `/voice sip` — set up SIP trunking
- `/voice recording` — set up call recording

## Agent: telnyx-agent

## Routing

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
Ask what the user wants. Route to one of 6 flows (A–F).
Full call flows, SIP setup, and AI assistant steps: see `commands/voice-flows.md`

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
