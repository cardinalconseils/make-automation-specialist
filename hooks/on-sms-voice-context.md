# Hook: on-sms-voice-context

**Event:** `before.agent.respond`
**Purpose:** Detect SMS, voice, or Telnyx-specific intent in user messages and route to telnyx-agent.

---

## Trigger Keywords

Scan the user's message (case-insensitive) for any of the following keyword groups:

### SMS / MMS
`sms`, `text message`, `texting`, `mms`, `multimedia message`,
`two-way sms`, `two-way text`, `10dlc`, `tcpa`, `a2p`,
`opt-out`, `stop keyword`, `unsubscribe`, `bulk sms`, `mass text`

### Voice Calls
`voice call`, `phone call`, `outbound call`, `inbound call`,
`call routing`, `call recording`, `ivr`, `phone menu`,
`press 1`, `press 2`, `dial`, `dialing`, `auto-dial`

### AI Voice / Receptionist
`ai receptionist`, `voice bot`, `phone bot`, `virtual receptionist`,
`telnyx assistant`, `phone assistant`, `auto-answer`, `answer calls`,
`ai answers`, `voice agent`

### Telnyx Platform
`telnyx`, `call control`, `messaging profile`, `call control application`,
`number intelligence`, `sip trunk`, `sip trunking`, `webrtc`,
`click to call`, `click-to-call`, `texml`

### Phone Numbers
`buy a number`, `purchase a number`, `phone number setup`,
`toll-free`, `toll free`, `800 number`, `port a number`, `port my number`,
`did number`, `virtual number`

---

## Action

When any keyword is detected:

1. **Check if telnyx-agent is already active** — if yes, NO-OP (already routed)

2. **Check for `TELNYX_API_KEY`:**
   - Present: signal routing to `telnyx-agent` with the user's message as context
   - Missing: surface setup instructions immediately
     ```
     TELNYX SETUP REQUIRED
     ──────────────────────
     I detected a request that needs Telnyx, but your API key is not configured.

     To set it up:
     1. Log in at telnyx.com
     2. Go to Auth → API Keys → Create API Key
     3. Add to your environment: TELNYX_API_KEY=your-key-here
     4. Restart this session, then try again.
     ```

3. **Signal to telnyx-agent:** Pass the original user message and detected keyword category so the agent can skip Phase 0 greeting and jump directly to the relevant flow.

---

## NO-OP Conditions (do NOT activate)

- Message contains `telegram` but does NOT contain any SMS/voice/Telnyx keyword from the lists above — Telegram alerts ≠ Telnyx communications platform
- telnyx-agent is already the active agent
- Message is about Make.com webhook modules without voice/SMS context (e.g., "webhook trigger for email")
- Message is about n8n, Zapier, or other automation platforms unrelated to voice/SMS

---

## Disambiguation — Telegram vs Telnyx

Telegram is a messaging app used for alert notifications in this plugin.
Telnyx is a carrier-grade communications API for SMS, voice, and SIP.

**These are completely different.** The hook must NOT activate when the user says:
- "Send a Telegram alert"
- "Telegram bot"
- "Telegram notification"
- "Connect Telegram"

The hook SHOULD activate when the user says:
- "Send an SMS to my customer"
- "Set up a phone call"
- "I need a Telnyx number"
- "Build an IVR menu"

If the message contains both "telegram" and a voice/SMS keyword (e.g., "Send both a Telegram alert and an SMS"), activate the hook — the user wants both.

---

## Logging

When this hook activates, note in `.make/logs/session.md`:
```
[HH:mm] on-sms-voice-context fired — keyword: [detected keyword] — routed to telnyx-agent
```
