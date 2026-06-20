# Telnyx Expert — SMS and MMS

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Messaging Profile

A Messaging Profile groups phone numbers and defines:
- Inbound webhook URL (where Telnyx POSTs received messages)
- Outbound webhook URL (delivery receipts)
- Enabled regions/features

**Setup flow:**
1. `mcp__telnyx__create_messaging_profile` — create profile with webhook URL
2. `mcp__telnyx__update_phone_number_messaging_settings` — assign number to profile

---

## Sending SMS

```
mcp__telnyx__send_message
  from: "+15141234567"      ← your Telnyx number
  to:   "+15140000000"      ← recipient
  text: "Hello!"
  messaging_profile_id: "abc-123"
```

---

## Inbound SMS Webhook Payload

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
In Make.com: use a **Custom Webhook** trigger, then map `{{1.data.payload.text}}`.

---

## Two-Way SMS Flow in Make.com

```
[Webhook trigger: inbound message]
  → [Set Variable: from = 1.data.payload.from.phone_number]
  → [Set Variable: text = 1.data.payload.text]
  → [Router]
      ├─ Filter: contains(lower(text); "stop") → [Update contact: opted_out=true] → end
      ├─ Filter: contains(lower(text); "help") → [Telnyx: send_message help text]
      └─ Default → [Your business logic] → [Telnyx: send_message reply]
```

---

## 10DLC and TCPA Compliance (US A2P SMS)

Required before sending bulk SMS to US numbers:

1. **Brand registration** — register your company via Telnyx portal
2. **Campaign registration** — describe your use case (marketing, OTP, notifications)
3. **10DLC approval** — takes 3–5 business days; numbers won't send until approved
4. **STOP keyword** — must handle opt-outs; Telnyx does this automatically for
   registered campaigns
5. **Consent documentation** — keep records of how each recipient opted in

**CASL (Canada):** Express consent required before sending commercial messages to
Canadian numbers. See `COMPLIANCE.md` for full CASL/PIPEDA guidance.

---

## MMS Gotchas

- MMS only works on US and Canadian numbers
- Max attachment size: 1.5 MB per message
- Supported types: JPEG, PNG, GIF, MP4 (video), MP3 (audio)
- International MMS not supported — message will fail if `to` is non-US/CA

---

## Debugging SMS Delivery

1. `mcp__telnyx__get_message` — get status of a specific message by ID
2. Check: `status` field — `received`, `sent`, `delivered`, `delivery_failed`
3. For failures: check `errors` array in message response for carrier rejection codes

| Problem | Check |
|---------|-------|
| SMS not delivered | Is number on a Messaging Profile? Is 10DLC approved? |
| Webhook not received | Is URL publicly accessible? Check Telnyx webhook logs in portal |
