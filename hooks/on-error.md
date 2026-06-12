# Hook: on-error

**Event:** error
**Trigger:** Fires on any unhandled error in the plugin execution

## Purpose

Catch errors that escape normal execution flow. Attempt recovery. Alert. Log. Surface.

## Error Categories

### Category A — Recoverable (auto-handle)
- Network timeout on MCP call → retry with backoff
- Rate limit hit → wait and retry
- Temporary Make.com API unavailability → wait 30s, retry

Auto-recovery:
1. Wait (10s for timeout, 60s for rate limit, 30s for unavailability)
2. Retry once
3. If success → log recovery, continue
4. If failure → escalate to Category B

### Category B — Needs User (surface + alert)
- Invalid Make.com API key
- Scenario not found (deleted externally)
- Permission denied on MCP call
- Data validation error (missing required field)
- Make.com plan limit reached

Response:
1. Call execution-logger → write error log
2. Call alert-dispatcher → send Telegram alert
3. Show user plain-language explanation + specific action to take

### Category C — Unknown / Unexpected
- Unrecognized error code
- Plugin internal error
- MCP protocol error

Response:
1. Call execution-logger → write error log with full context
2. Call alert-dispatcher → send Telegram alert flagged "needs investigation"
3. Show user:

```
Something unexpected happened that I don't recognize.

I've logged the details and sent you a Telegram alert.
Please share the log with your developer:
.make/logs/{log-filename}

In the meantime, your existing Make.com scenarios are 
not affected — I wasn't able to complete the action I 
was working on.
```

## Error Translation Dictionary

Translate these common API errors to plain language:

| Raw error | Plain language |
|-----------|---------------|
| `401 Unauthorized` | "Your Make.com API key is not working. It may have expired or been revoked." |
| `403 Forbidden` | "You don't have permission to do that in Make.com. Check your API key scope." |
| `404 Not Found` | "The scenario I was looking for doesn't exist in Make.com anymore. It may have been deleted." |
| `429 Too Many Requests` | "Make.com is asking me to slow down. I'll wait a moment and try again." |
| `500 Internal Server Error` | "Make.com is having a problem on their end. I'll try again in 30 seconds." |
| `503 Service Unavailable` | "Make.com appears to be down or in maintenance. Check status.make.com." |
| Connection timeout | "I couldn't reach Make.com. Check your internet connection." |
| `ECONNREFUSED` | "I couldn't connect to the service. It may be offline." |

Never show raw error messages or stack traces to the user.

## Recovery Audit Trail

Write to `.make/logs/recovery-log.md`:

```markdown
## {timestamp}
Error type: {category A/B/C}
Error: {raw error — for debugging}
Recovery attempted: {yes/no}
Recovery succeeded: {yes/no}
Alert sent: {yes/no}
User notified: {yes/no}
Resolution: {pending / resolved / abandoned}
```
