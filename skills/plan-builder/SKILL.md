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

### 2. Detect AI Requirements

Before selecting modules, check if the automation requires AI:
- Is there an `ai_required: true` flag in the input?
- Does the business requirement contain AI signal phrases?
- Is there an AI Agent Blueprint from `ai-agent-designer`?

**If AI is required:**
1. Load the AI Agent Blueprint from `ai-agent-designer` output (or call the skill now)
2. Load the pattern from `agent-pattern-library`
3. Look up exact module specs via `ai-docs-researcher`
4. Incorporate the AI steps into the module sequence below
5. Add AI token cost to the cost estimate (in addition to Make.com operations)

**AI-specific module selection hierarchy** (for AI steps only):

1. **Native Make.com AI module** — check for Anthropic, OpenAI, Google AI modules first
2. **OpenAI-compatible HTTP call** — if provider has no native module but is OpenAI-compatible
3. **HTTP module with custom auth** — absolute last resort, document clearly

For the AI module, always call `ai-docs-researcher` before writing the blueprint.
Never guess model IDs or field names for AI modules.

---

### 3. Select Make.com Modules (Non-AI Steps)

For each non-AI step, follow this selection hierarchy — in order, no skipping:

1. **Native Make.com app module** — always check first. Call `apps_recommend` then `app-modules_list` for every service involved.
2. **Composio connector** — if no native module exists, check if Composio covers it (Composio MCP available). Composio provides 250+ app connectors and handles OAuth automatically.
3. **HTTP module** — only if neither a native module nor a Composio connector exists. Document why in the plan: "No native module or Composio connector found for [service/endpoint]. Using HTTP with manual auth."

**Hard rule: HTTP is forbidden as a default choice.** It is the last resort, not the starting point.

Additional rules:
- Check if selected integrations are available in the workspace plan tier
- Composio connections must be set up and verified before being referenced in a plan

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
