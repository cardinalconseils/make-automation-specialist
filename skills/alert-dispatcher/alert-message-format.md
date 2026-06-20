# Alert Message Format

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

## Examples

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
