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

Plain-language Telegram message. No raw JSON. No stack traces.

```
Make.com Alert — {workspace_name}

What happened: {plain-language error description}

Scenario: {scenario_name}
Time: {timestamp in user's timezone if known, else UTC}
Status: {Failed / Paused / Needs attention}

What to do: {specific action recommendation}

Full details: .make/logs/{log_filename}
```

### Examples

**Scenario failure:**
```
Make.com Alert — My Agency Workspace

What happened: Your "Lead Intake to CRM" scenario failed 
because the HubSpot connection timed out. The lead from 
John Smith was not saved to your CRM.

Scenario: Lead Intake to CRM
Time: June 9, 2026 at 2:41 PM
Status: Failed (3 attempts)

What to do: Check that your HubSpot connection is still 
active in Make.com, then manually enter the lead or 
re-trigger the webhook.

Full details: .make/logs/2026-06-09-1441-lead-intake.md
```

**Operation limit warning:**
```
Make.com Alert — My Agency Workspace

What happened: You've used 95% of your monthly Make.com 
operations (9,503 of 10,000). Make.com will pause your 
scenarios when the limit is reached.

What to do: Either upgrade your Make.com plan or temporarily 
pause low-priority automations to save operations for your 
most important ones.

Your plan resets on: {plan_reset_date}
```

## Alert Channel Tiers

Alerts are sent via a 3-tier channel system based on severity and channel availability:

### Tier 1 — Telegram (primary)
Use for all alerts when `TELEGRAM_CHAT_ID` is set.
- Send via `mcp__telnyx__send_message` to the Telegram bot
- Parse mode: plain text (no markdown)
- Keep under 500 characters when possible

### Tier 2 — SMS via Telnyx (secondary fallback)
Use when Telegram fails or `TELEGRAM_CHAT_ID` is missing, and `TELNYX_ALERT_PHONE` is set.

**Level 2 gate required** — show number and estimated cost before sending.

SMS alert format (140 chars max for reliability):
```
Make.com Alert: {scenario_name} failed. {one-line error}. Check .make/logs/ for details.
```

Send via: `mcp__telnyx__send_message` with `to: TELNYX_ALERT_PHONE`

### Tier 3 — Voice call (CRITICAL failures only)
Use only for P0 failures (payment processing stopped, complete workspace down)
when both Telegram and SMS have failed or are unavailable.

Requires `TELNYX_ALERT_PHONE` and a configured Call Control Application.
**Level 2 gate required.**

1. `mcp__telnyx__make_call` to `TELNYX_ALERT_PHONE`
2. On `call.answered`: `mcp__telnyx__speak` with:
   "Make.com critical alert. Your automation workspace has a critical failure. Please check your logs immediately. Goodbye."
3. `mcp__telnyx__hangup`

### Fallback — Missed alerts log
If all tiers fail:
1. Log alert content to `.make/logs/missed-alerts.md`
2. Surface to user in conversation: "I tried to send an alert but all channels failed.
   Here's what I would have sent: [message]"

## Environment Variables

- `TELNYX_API_KEY` — Telnyx API key (required for all tiers)
- `TELEGRAM_CHAT_ID` — Destination Telegram chat ID (Tier 1)
- `TELNYX_ALERT_PHONE` — Phone number for SMS/voice alerts (Tier 2/3) — format: +15141234567

If `TELNYX_API_KEY` is missing: skip all tiers, log to missed-alerts.md.

## Rate Limiting

Do not send more than 5 alerts per 15-minute window to avoid flooding.
If threshold exceeded: batch remaining alerts into a single summary message.
Voice calls: maximum 1 per hour regardless of failure count.
