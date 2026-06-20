# Telnyx Expert — Observability and Debugging

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Portal and Diagnostic Tools

```
mcp__telnyx__get_webhook_events              — retrieve recent webhook events for debugging
mcp__claude_ai_Telnyx__open_voice_monitor    — open voice monitor portal (live call view)
mcp__claude_ai_Telnyx__open_usage_cost_explorer — open cost explorer portal
```

---

## Debugging SMS Delivery

1. `mcp__telnyx__get_message` — get status of a specific message by ID
2. Check: `status` field — `received`, `sent`, `delivered`, `delivery_failed`
3. For failures: check `errors` array in message response for carrier rejection codes

---

## Debugging Voice Calls

1. `mcp__telnyx__get_webhook_events` — see all events for a call
2. `mcp__claude_ai_Telnyx__open_voice_monitor` — real-time call state
3. Check: Is `call_control_id` correct? Is webhook URL reachable from internet? TLS valid?

---

## Common Issues Quick Reference

| Problem | Check |
|---------|-------|
| SMS not delivered | Is number on a Messaging Profile? Is 10DLC approved? |
| Webhook not received | Is URL publicly accessible? Check Telnyx webhook logs in portal |
| Call hangs up immediately | Is connection active? Does webhook URL respond with HTTP 200? |
| AI assistant silent | Check system_prompt length; verify voice model name exact spelling |
| Recording URL expired | Always save within 24 hours — set up automatic persistence pattern |

---

## Webhook Verification Checklist

When webhooks stop arriving:
- [ ] URL is publicly accessible (not localhost)
- [ ] URL returns HTTP 200 within 5 seconds
- [ ] TLS certificate is valid (Telnyx rejects self-signed certs)
- [ ] Correct URL is set on the right resource (Messaging Profile OR Call Control App)
- [ ] No firewall blocking inbound POST from Telnyx IP ranges

---

## Reading Webhook Event History

```
mcp__telnyx__get_webhook_events
```
Returns a paginated list of recent webhook deliveries including:
- `event_type` — what happened
- `payload` — full event data
- `delivered_at` — timestamp
- `response_code` — what your server returned (should be 200)
