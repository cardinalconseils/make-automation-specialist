---
name: execution-logger
description: Writes timestamped execution logs and changelog entries after every automation action. Called by post-execute hook. Append-only — never overwrites the audit trail.
---

# Skill: execution-logger

Writes timestamped logs after every execution. Called by post-execute hook.
Also writes changelog entries after scenario fixes.

## Execution Log

Write to `.make/logs/{timestamp}-{scenario-slug}.md` after every execution.

### Format

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

## Changelog Entry

Append to `.make/changelog/{scenario-id}.md` after every fix.

### Format

```markdown
## {YYYY-MM-DD HH:MM} — {change-type}

**Agent:** scenario-auditor
**Approved by:** User (session {date})
**Execution log:** `.make/logs/{log-filename}`

### Issue Fixed
{Plain-language description of the problem that was fixed}

### What Changed

**Before:**
{Relevant before state — plain language + key config values}

```json
{minimal before JSON snippet if useful}
```

**After:**
{Relevant after state — plain language + key config values}

```json
{minimal after JSON snippet if useful}
```

### Outcome
{success | failed}
{Description of outcome}

---
```

## Append-Only Rule

Changelog files are NEVER overwritten. Always append. The changelog is an audit trail.

## File Naming

Log files: `{YYYY-MM-DD}-{HHmm}-{scenario-slug}.md`
Example: `2026-06-09-1441-lead-intake-crm.md`

Slugify scenario name: lowercase, spaces to hyphens, remove special characters.
Max 40 characters for the slug portion.

## Directory Creation

If `.make/logs/` or `.make/changelog/` directories don't exist, create them before writing.
Same for all `.make/` subdirectories.
