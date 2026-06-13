---
description: Activate Telnyx Communications Specialist for full platform management
allowed-tools: Agent
---

# /telnyx Command

Activates the Telnyx Communications Specialist for full platform management.

## Triggers

- `/telnyx` — general Telnyx account and platform menu
- `/telnyx sms` — jump directly to SMS setup
- `/telnyx voice` — jump directly to voice/call setup
- `/telnyx numbers` — jump directly to phone number management
- `/telnyx ai` — jump directly to AI assistant setup
- `/telnyx status` — account discovery only, display status card

## Agent: telnyx-agent

## Flow

### Phase 0 — Account Discovery
Run parallel reads to get current account state:
- `list_phone_numbers` — what numbers you own
- `list_messaging_profiles` — SMS routing configuration
- `list_call_control_applications` — voice routing configuration
- `list_connections` — connection types in use
- `list_assistants` — any existing AI assistants

Display status card showing counts and key identifiers.

### Phase 1 — Capability Menu
Present the 8 capability areas:

```
TELNYX CAPABILITIES
────────────────────
What would you like to do?

1. SMS / Text Messaging    — send texts, set up two-way SMS, compliance
2. Voice Calls             — outbound calling, IVR, inbound routing
3. AI Receptionist         — voice bot that answers calls automatically
4. SIP Trunking            — connect your office phone system to Telnyx
5. Phone Numbers           — buy, search, manage, or port numbers
6. Call Recording          — record calls and store them
7. WebRTC / Browser Calls  — click-to-call from a website or app
8. Number Intelligence     — look up carrier, line type, CNAM

Type a number or describe what you need.
```

### Phase 2 — Route to Capability Flow
Based on selection, run the corresponding flow from telnyx-expert skill.
Always show a plan with costs before executing.

### Phase 3 — Execute and Test
Follow telnyx-agent workflow: narrate each call, apply approval gates, run test.

## Arguments

- No args: full menu
- `sms`: skip to SMS readiness check + SMS flows
- `voice`: skip to voice readiness check + voice flows
- `numbers`: skip to number management
- `ai`: skip to AI assistant setup
- `status`: account discovery only, no action
