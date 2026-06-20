# Telnyx Expert — Voice Calls (Call Control API)

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Event Flow

Every outbound call goes through this sequence:
```
make_call → call.initiated → call.ringing → call.answered → [commands] → call.hangup
```
Telnyx POSTs each event to your webhook URL (configured on the Call Control Application).

---

## Making an Outbound Call

```
mcp__telnyx__make_call
  connection_id: "your-call-control-app-id"
  to:   "+15140000000"
  from: "+15141234567"
  webhook_url: "https://your-server.com/telnyx-webhook"
```

---

## Call Control Commands (in-call actions)

Use these after `call.answered` webhook fires:

| Tool | Purpose | Key params |
|------|---------|-----------|
| `mcp__telnyx__speak` | Text-to-speech | `call_control_id`, `payload` (text), `voice`, `language` |
| `mcp__telnyx__playback_start` | Play audio file | `call_control_id`, `audio_url` |
| `mcp__telnyx__playback_stop` | Stop audio | `call_control_id` |
| `mcp__telnyx__send_dtmf` | Send keypad tones | `call_control_id`, `digits` |
| `mcp__telnyx__transfer` | Transfer call | `call_control_id`, `to` |
| `mcp__telnyx__hangup` | End call | `call_control_id` |

---

## IVR DTMF Pattern (in Make.com)

```
[Webhook: call.answered] → [speak: "Press 1 for sales, 2 for support"]
  → [Webhook: call.dtmf.received]
      → [Router]
          ├─ digit = 1 → [transfer to sales queue]
          └─ digit = 2 → [transfer to support queue]
```

---

## Call Recording

1. Enable recording on the Call Control Application (portal or `update_call_control_application`)
2. Recording URL arrives in `call.recording.saved` webhook event
3. **Gotcha:** Recording URL is time-limited (expires in ~24 hours)
4. **Best practice:** On `call.recording.saved`, immediately save the file to cloud storage

```
[Webhook: call.recording.saved] → [HTTP: download recording] → [Telnyx storage / S3: upload]
```

---

## Call Control vs TeXML — When to Use Each

| Use Case | Recommendation |
|----------|---------------|
| Simple IVR, static flow | TeXML (less infrastructure) |
| Dynamic/personalized call flow | Call Control API |
| Real-time decisions based on caller input | Call Control API |
| Quick setup without server | TeXML |
| AI-driven conversations | AI Assistants (see `AI-ASSISTANTS.md`) |

---

## Debugging Voice Calls

1. `mcp__telnyx__get_webhook_events` — see all events for a call
2. `mcp__claude_ai_Telnyx__open_voice_monitor` — real-time call state
3. Check: Is call_control_id correct? Webhook reachable from internet? TLS valid?

| Problem | Check |
|---------|-------|
| Call hangs up immediately | Is connection active? Check webhook URL responds with HTTP 200 |
| Recording URL expired | Always save within 24 hours — set up automatic persistence |
