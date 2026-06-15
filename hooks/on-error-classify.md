# Hook: on-error-classify

**Event:** before.agent.respond (PreToolUse equivalent — fires when error patterns detected in context)
**Type:** Deterministic classifier — always runs, never blocks, enriches context

## Purpose

When the user message or tool output contains a Make.com error pattern, automatically classify it against the taxonomy and prepend the classification to the agent's context. This ensures the taxonomy is always consulted before generating a response.

## Trigger Conditions

Fire this hook when the incoming text contains ANY of:
- An HTTP status code reference (400, 401, 403, 404, 409, 422, 429, 500, 502, 503, 504)
- A Make error type keyword: `DataError`, `RuntimeError`, `ConnectionError`, `RateLimitError`, `AuthorizationError`, `AccessDeniedError`, `DuplicateDataError`, `InconsistencyError`, `IncompleteDataError`
- `isinvalid: true`
- `"The connection is not available"`
- `__EMPTY__`
- `[object Object]`
- `Unable to parse range`
- `invalid_grant`
- `channel_not_found`
- `INVALID_VALUE_FOR_COLUMN`
- `timeout` / `timed out`
- `operations limit`

## Action

1. Scan the incoming context for patterns above
2. For each match, look up the likely taxonomy code(s)
3. Prepend to agent context:

```
[Auto-classified from Make Error Classifier]
Detected pattern(s): {CODE1} — {Title1}, {CODE2} — {Title2}
→ Load taxonomy/make-failure-taxonomy.md and cite {CODE} in response.
```

## Pattern → Code Mapping

| Pattern | Code(s) |
|---------|---------|
| 401 / AuthorizationError / invalid_grant | `HTTP-401`, `CONN-001` |
| 403 / AccessDeniedError | `HTTP-403`, `CONN-002` |
| 404 / Not Found | `HTTP-404` |
| 409 / DuplicateDataError | `HTTP-409`, `MAKE-DUP` |
| 422 / ValidationError | `HTTP-422` |
| 429 / RateLimitError | `HTTP-429`, `RATE-001` |
| 500/502/503/504 / ConnectionError | `HTTP-5xx` |
| DataError | `MAKE-DATA` |
| InconsistencyError | `MAKE-INCONSIST` |
| RuntimeError | `MAKE-RUNTIME` |
| IncompleteDataError | `MAKE-INCOMPLETE` |
| isinvalid: true | `BLUEPRINT-001` |
| "The connection is not available" | `CONN-001` |
| `__EMPTY__` | `APP-GSHEETS-002` |
| `[object Object]` | `DATA-005` |
| Unable to parse range | `APP-GSHEETS-001` |
| channel_not_found | `APP-SLACK-001` |
| INVALID_VALUE_FOR_COLUMN | `APP-AIRTABLE-001` |
| timeout / timed out / 40 second | `EXEC-001` |
| operations limit | `RATE-002` |

## Rules
- NEVER block execution — this hook only enriches context
- NEVER display classification to user directly — it's context enrichment only
- Always exit successfully regardless of classification result
