# Execution Log Format

Write to `.make/logs/{timestamp}-{scenario-slug}.md` after every execution.

```markdown
# Execution Log

**Date:** {YYYY-MM-DD HH:MM UTC}
**Agent:** {agent-id}
**Action Type:** {build | fix | audit | test}
**Scenario:** {name} ({make_scenario_id})
**Status:** {success | failed | partial}
**Duration:** {seconds}s

## What Was Done
{Plain-language description of what the agent did}

## MCP Calls Made
| Call | Target | Status | Duration |
|------|--------|--------|----------|
| create_scenario | make | success | 1.2s |
| activate_scenario | make | success | 0.3s |
| send_message | telnyx | skipped (no failure) | — |

## Operations Used
| Item | Count |
|------|-------|
| Make.com operations this run | {n} |
| Operations used this month (total) | {n} |
| Plan limit | {n} |

## Estimated Cost This Run
| Item | Cost |
|------|------|
| Make.com | ${n} |
| External APIs | ${n} |
| Total | ${n} |

## Outcome
{Plain-language outcome description}

## Errors
{None — or error description in plain language}

## Recovery Actions Taken
{None — or description of auto-recovery attempts}

## Alert Sent
{None — or "Telegram alert sent at {time}"}
```
