---
description: Research a service or integration before building — checks Make.com native app support, API docs, rate limits, webhook availability, and gotchas
allowed-tools: Agent
---

# /research — Integration Research

Dispatch the deep-researcher agent to investigate a Make.com integration before building.

## Usage

```
/research [service name or integration description]
```

Examples:
- `/research Stripe webhooks`
- `/research Notion database integration`
- `/research how to connect Shopify orders to Make.com`
- `/research Gmail watch for new emails`

## Dispatch

Route to `agents/deep-researcher.md` with the user's query as the research topic.

Pass this context to the agent:
- The service or integration described by the user
- Any specific questions the user raised (rate limits, trigger type, etc.)
- Current project context from `.make/context/context.md` if it exists

## Output

The agent writes findings to `.make/research/{slug}/report.md` and
surfaces a plain-language summary to the user with a recommended approach.

If a Make.com native app exists: show available modules and any key limitations.
If no native app: show the best HTTP workaround and estimated complexity.
