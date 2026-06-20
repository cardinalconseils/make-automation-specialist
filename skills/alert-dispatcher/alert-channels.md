# Alert Channel Tiers

Alerts are sent via a 3-tier channel system based on severity and channel availability.

## Tier 1 — Telegram (primary)

Use for all alerts when `TELEGRAM_CHAT_ID` is set.
- Send via `mcp__telnyx__send_message` to the Telegram bot
- Parse mode: plain text (no markdown)
- Keep under 500 characters when possible

## Tier 2 — SMS via Telnyx (secondary fallback)

Use when Telegram fails or `TELEGRAM_CHAT_ID` is missing, and `TELNYX_ALERT_PHONE` is set.

**Level 2 gate required** — show number and estimated cost before sending.

SMS alert format (140 chars max for reliability):
```
Make.com Alert: {scenario_name} failed. {one-line error}. Check .make/logs/ for details.
```

Send via: `mcp__telnyx__send_message` with `to: TELNYX_ALERT_PHONE`

## Tier 3 — Voice call (CRITICAL failures only)

Use only for P0 failures (payment processing stopped, complete workspace down)
when both Telegram and SMS have failed or are unavailable.

Requires `TELNYX_ALERT_PHONE` and a configured Call Control Application.
**Level 2 gate required.**

1. `mcp__telnyx__make_call` to `TELNYX_ALERT_PHONE`
2. On `call.answered`: `mcp__telnyx__speak` with:
   "Make.com critical alert. Your automation workspace has a critical failure. Please check your logs immediately. Goodbye."
3. `mcp__telnyx__hangup`

## Fallback — Missed alerts log

If all tiers fail:
1. Log alert content to `.make/logs/missed-alerts.md`
2. Surface to user in conversation: "I tried to send an alert but all channels failed.
   Here's what I would have sent: [message]"
