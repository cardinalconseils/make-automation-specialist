---
name: error-handler
description: "Error handling patterns, directives, and audit checklists for Make.com scenarios"
allowed-tools: Read, Grep, Glob
---

# Error Handler Skill

Load this skill when designing, auditing, or reviewing Make.com scenarios.
It is the authoritative reference for error handling patterns, directives, and audit checklists.

See [ERROR-HANDLER-DIRECTIVES.md](./ERROR-HANDLER-DIRECTIVES.md) for:
- The five directive types (Resume, Rollback, Ignore, Break, Commit) and decision table
- Error variables available in handler routes
- `iferror()` expression-level handling
- Incomplete executions behavior and gotchas
- Common error scenarios and fixes

See [ERROR-HANDLER-PATTERNS.md](./ERROR-HANDLER-PATTERNS.md) for:
- Architecture patterns (Log+Alert, Dead Letter Queue, Router by Error Code, Compensation)
- Blueprint JSON pattern for error handler config
- 8-point audit checklist

---

## Module-Level Retry Settings

Configure retries **before** adding error handler routes. Built-in retries handle
transient failures (network timeouts, 429 rate limits, 503 service unavailable).

**Always set for HTTP / API modules:**
- Max number of errors: 2–3
- Interval between errors: 10–60 seconds (exponential backoff: 10s, 30s, 60s)

**Where to configure:** Module settings → Advanced → Error handling → Enable retries

**Gotcha:** If a module fails with no retry configured, it immediately fires the error
handler route (or halts the scenario if no route exists).
