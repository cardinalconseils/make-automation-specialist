---
name: alert-dispatcher
description: Sends Telegram alerts via Telnyx MCP when automations fail. Called by post-execute and on-error hooks. Handles rate limiting, fallback logging, and message formatting.
---

# Skill: alert-dispatcher

Sends Telegram alerts via Telnyx MCP when automations fail.
Called by post-execute hook and on-error hook.

## When to Alert

Alert conditions (any of these triggers a send):
1. Automation execution failed after 2 retry attempts
2. Make.com scenario returned error status
3. MCP call failed (Make.com unreachable, rate limited, etc.)
4. Monthly operation usage exceeded 95% of plan limit
5. Critical compliance issue detected during audit
6. Audit found hardcoded credentials in a scenario

Do NOT alert for:
- Warnings or info-level audit findings
- Successful executions (no spam)
- First retry attempt (wait for final failure)

## Message Format

See [alert-message-format.md](alert-message-format.md) for Telegram message template and examples.

## Alert Channel Tiers

See [alert-channels.md](alert-channels.md) for the 3-tier channel system (Telegram → SMS → Voice).

## Environment Variables

- `TELNYX_API_KEY` — Telnyx API key (required for all tiers)
- `TELEGRAM_CHAT_ID` — Destination Telegram chat ID (Tier 1)
- `TELNYX_ALERT_PHONE` — Phone number for SMS/voice alerts (Tier 2/3) — format: +15141234567

If `TELNYX_API_KEY` is missing: skip all tiers, log to missed-alerts.md.

## Rate Limiting

Do not send more than 5 alerts per 15-minute window to avoid flooding.
If threshold exceeded: batch remaining alerts into a single summary message.
Voice calls: maximum 1 per hour regardless of failure count.
