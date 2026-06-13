---
description: Activate Telnyx SMS specialist for text messaging setup, troubleshooting, and compliance
allowed-tools: Agent
---

# /sms Command

Activates the Telnyx SMS specialist flow for text messaging setup, troubleshooting, and compliance.

## Triggers

- `/sms` — SMS readiness check + flow menu
- `/sms send` — send a one-off SMS message
- `/sms setup` — set up outbound SMS capability
- `/sms twoway` — set up two-way SMS (receive + reply)
- `/sms compliance` — 10DLC/TCPA/CASL compliance check
- `/sms debug` — troubleshoot SMS delivery issues

## Agent: telnyx-agent

## Flow

### Phase 0 — SMS Readiness Check
Run these reads to assess current SMS capability:
- `list_phone_numbers` — do you have numbers with SMS feature?
- `list_messaging_profiles` — is a messaging profile configured?

Display readiness status:
```
SMS READINESS CHECK
────────────────────
SMS-capable numbers: [count] ([list])
Messaging profiles:  [count]

Status: [Ready / Partial setup / Not configured]
```

If not configured: offer to run setup before proceeding.

### Phase 1 — Intent Discovery
Ask what the user wants to accomplish. Route to one of 5 flows:

**Flow A — Send a one-off SMS:**
1. Confirm from-number, to-number, message text
2. Level 2 gate: show recipient + cost (~$0.004/msg US)
3. `send_message`
4. `get_message` to confirm delivery status

**Flow B — Set up outbound SMS:**
1. Check for SMS-capable number; offer to purchase if none
2. Create or select messaging profile
3. Assign number to profile
4. Test: send SMS to user's own number

**Flow C — Set up two-way SMS (receive + reply):**
1. Outbound setup (Flow B) if not already done
2. Ask for webhook URL (where to receive inbound messages)
3. Update messaging profile with inbound webhook URL
4. Explain Make.com Custom Webhook trigger setup
5. Walk through two-way SMS scenario design in Make.com
6. Test: send inbound SMS to Telnyx number, confirm webhook fires

**Flow D — Compliance check:**
For US A2P SMS campaigns:
1. Ask: "How many recipients per month?"
2. Ask: "How did recipients consent to receive messages?"
3. Assess 10DLC registration status
4. Explain registration steps if needed
5. Surface STOP keyword handling and opt-out flow
6. For Canadian recipients: explain CASL requirements
7. Output: compliance readiness report in `.make/logs/sms-compliance-{{date}}.md`

**Flow E — Troubleshoot delivery:**
1. Ask for message ID or recipient number
2. `get_message` for status and error details
3. Translate any error codes to plain language
4. Common checks: number on messaging profile? 10DLC approved? Balance sufficient?
5. Recommend specific fix

### Phase 2 — Plan with Costs
Show estimated cost for any chargeable action before proceeding.

### Phase 3 — Execute with Approval Gates
Apply Level 1/2/3 gates per telnyx-expert skill Section 13.
Narrate each MCP call.

### Phase 4 — Test
Always send a test SMS to the user's own mobile number.
Only mark setup complete after user confirms receipt.

### Phase 5 — Log
Write to `.make/logs/telnyx-{{formatDate(now; "YYYY-MM-DD")}}.md`
