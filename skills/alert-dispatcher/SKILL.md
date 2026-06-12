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

## Sending via Telnyx MCP

Use Telnyx MCP to send via Telegram:
- Recipient: `TELEGRAM_CHAT_ID` from environment
- Parse Mode: plain text (no markdown in Telegram message)
- Keep under 500 characters when possible

If Telnyx MCP is unavailable:
1. Log alert content to `.make/logs/missed-alerts.md`
2. Surface to user in conversation: "I tried to send a Telegram alert but the Telnyx
   MCP is not connected. Here's what I would have sent: [message]"

## Environment Variables Required

- `TELNYX_API_KEY` — Telnyx API key
- `TELEGRAM_CHAT_ID` — Destination Telegram chat ID

If either is missing, skip alert send and log to missed-alerts.md.

## Rate Limiting

Do not send more than 5 alerts per 15-minute window to avoid Telegram flooding.
If threshold exceeded: batch remaining alerts into a single summary message.
