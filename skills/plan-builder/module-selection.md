# Module Selection — Non-AI Steps

## Selection Hierarchy

For each non-AI step, follow this order — no skipping:

1. **Native Make.com app module** — always check first. Call `apps_recommend` then `app-modules_list` for every service involved.
2. **Composio connector** — if no native module exists, check if Composio covers it. Composio provides 250+ app connectors and handles OAuth automatically.
3. **HTTP module** — only if neither a native module nor a Composio connector exists. Document why in the plan.

**Hard rule: HTTP is forbidden as a default choice.** It is the last resort, not the starting point.

Additional rules:
- Check if selected integrations are available in the workspace plan tier
- Composio connections must be set up and verified before being referenced in a plan

## Module Selection Reference

| Need | Native Module (use first) | Composio fallback | HTTP (last resort only) |
|------|--------------------------|-------------------|------------------------|
| Receive form data | Webhooks > Custom Webhook | — | HTTP > Webhook |
| Send email | Gmail / Mailgun / SendGrid | Composio Gmail/SMTP | Only for custom SMTP |
| Read spreadsheet | Google Sheets | Composio Google Sheets | Never |
| Write spreadsheet | Google Sheets | Composio Google Sheets | Never |
| CRM update | HubSpot / Pipedrive / Salesforce | Composio HubSpot/Pipedrive | Only for unsupported endpoints |
| Send Slack message | Slack | Composio Slack | Never |
| Send Telegram message | Telegram Bot | Composio Telegram | Telnyx via HTTP if no other option |
| Parse JSON | JSON > Parse JSON | — | — |
| Loop over array | Flow Control > Iterator | — | — |
| Branch logic | Flow Control > Router | — | — |
| Filter items | Flow Control > Filter | — | — |
| Aggregate results | Tools > Array Aggregator | — | — |
| Delay/pause | Flow Control > Sleep | — | — |
| No native module exists | — | Search Composio first | HTTP > Make a Request |
| Store data temporarily | Tools > Set Variable | — | — |
| Database query | Supabase / MySQL / PostgreSQL | Composio DB connectors | Never |
