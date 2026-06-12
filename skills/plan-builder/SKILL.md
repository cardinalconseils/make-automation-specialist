---
name: plan-builder
description: Constructs a structured AutomationPlan from a business requirement. Maps requirements to Make.com modules, designs error handling, and runs the guardrail checklist. Called by automation-planner and automation-specialist agents.
---

# Skill: plan-builder

Constructs a structured AutomationPlan from a business requirement.
Called by automation-planner agent and automation-specialist agent.

## Input Contract

Receive:
- `business_requirement` — structured summary from interview
- `available_mcps` — list of MCPs available in current session
- `workspace_context` — from `.make/workspace.json`
- `budget_constraint` (optional) — max operations/month or cost/month

## Process

### 1. Map Business Requirement to Make.com Architecture

Identify:
- **Trigger type:** Is this event-based (webhook/instant) or time-based (schedule)?
- **Data sources:** What APIs/services are involved?
- **Transformations:** What data manipulation is needed?
- **Actions:** What happens at the end (send, write, notify)?
- **Volume:** Estimated runs per day/month

### 2. Select Make.com Modules

For each identified step, select the appropriate module:
- Prefer native Make.com app modules over generic HTTP modules
- Use official integrations when available (reduces error handling burden)
- Check if selected integrations are available in workspace plan tier
- Note if any integration requires Composio or n8n as alternative

### 3. Design Error Handling

For every step that can fail (network, API, file operations):
- Add error handler route
- Define retry logic (default: 3 attempts, exponential backoff)
- Define escalation: log + Telegram alert if retries exhausted
- Define data: what gets logged on failure

### 4. Build Plan Document

Use the AutomationPlan template from automation-planner.md.

### 5. Return Plan

Return the complete plan markdown and the plan file path to the calling agent.

## Module Selection Reference

| Need | Preferred Module | Alternative |
|------|-----------------|-------------|
| Receive form data | Webhooks > Custom Webhook | HTTP > Webhook |
| Send email | Gmail / Mailgun / SendGrid | SMTP |
| Read spreadsheet | Google Sheets | Airtable |
| Write spreadsheet | Google Sheets | Airtable |
| CRM update | HubSpot / Pipedrive / Salesforce | HTTP module |
| Send Slack message | Slack | HTTP module |
| Send Telegram message | Telegram Bot | Telnyx via HTTP |
| Parse JSON | JSON > Parse JSON | Tools > Set Variable |
| Loop over array | Flow Control > Iterator | — |
| Branch logic | Flow Control > Router | — |
| Filter items | Flow Control > Filter | — |
| Aggregate results | Tools > Array Aggregator | — |
| Delay/pause | Flow Control > Sleep | — |
| HTTP call (no native) | HTTP > Make a Request | — |
| Store data temporarily | Tools > Set Variable | — |
| Database query | Supabase / MySQL / PostgreSQL | — |

## Guardrail Checklist

Before finalizing plan, confirm:
- [ ] Error handler on every network/API module
- [ ] Retry policy defined
- [ ] Telegram alert path for unresolvable failures
- [ ] Filter before any expensive downstream operations
- [ ] No hardcoded credentials — all via Make.com connection manager
- [ ] Operation count estimate included
- [ ] Cost estimate included
- [ ] Risk level assigned
