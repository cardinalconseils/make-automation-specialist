# Error Handler Skill

Load this skill when designing, auditing, or reviewing Make.com scenarios.
It is the authoritative reference for error handling patterns, directives, and audit checklists.

---

## 1. Error Handler Route Types

Every module can have an error handler route. When an error occurs, Make.com evaluates the route and takes one of five directives:

| Directive | What It Does | When to Use |
|-----------|-------------|-------------|
| **Resume** | Marks the error as handled; continues the scenario from the next module as if no error occurred | Non-critical data; partial success is acceptable (e.g., skip a bad row and continue) |
| **Rollback** | Rolls back the current execution; marks as incomplete; stops | Transactional workflows where partial execution is worse than no execution (e.g., order processing) |
| **Ignore** | Ignores the error; continues with the **same** module's output being empty | Only use when the module's output is truly optional and empty is fine |
| **Break** | Stops execution; saves the incomplete execution for manual review (30-day retention) | When human review is required before retrying |
| **Commit** | Commits all operations performed so far; stops the rest of the scenario | Use after a critical operation that must persist even if later steps fail |

**Decision table:**

```
Is the failed module's output required by downstream modules?
  ├─ Yes → Can we skip this item and continue with others?
  │        ├─ Yes (iterator context) → Resume
  │        └─ No → Break (for human review) or Rollback (for transactions)
  └─ No  → Ignore (if output not needed) or Resume (to log and continue)

Is this a transactional flow (payment, inventory, booking)?
  └─ Yes → Rollback

Is human review needed?
  └─ Yes → Break

Must prior operations persist even on later failure?
  └─ Yes → Commit
```

---

## 2. Module-Level Retry Settings

Configure retries **before** adding error handler routes. Built-in retries handle transient failures (network timeouts, 429 rate limits, 503 service unavailable) without consuming error handler routes.

**Always set for HTTP / API modules:**
- Max number of errors: 2–3
- Interval between errors: 10–60 seconds (use exponential backoff: 10s, 30s, 60s)

**Where to configure:** Module settings → Advanced → Error handling → Enable retries

**Gotcha:** If a module fails and has no retry configured, it immediately fires the error handler route (or halts the scenario if no route exists).

---

## 3. Architecture Patterns

### Pattern A — Log + Alert + Continue
Use for non-critical modules where partial data loss is acceptable.

```
[Module] → Error → [Set Variable: log entry] → [HTTP: send to log endpoint] → [Telegram: alert] → Resume
```

### Pattern B — Dead Letter Queue
Use for important data that must not be lost but can be retried later.

```
[Module] → Error → [Data Store: create record with payload + error] → [Telegram: alert with DLQ count] → Break
```
Schedule a separate scenario to retry DLQ records daily.

### Pattern C — Router by Error Code
Use for APIs that return predictable error codes with different remediation.

```
[Module] → Error →
  [Router]
    ├─ Filter: error.statusCode = 429 → [Tools: Sleep 60s] → Resume (retry via next execution)
    ├─ Filter: error.statusCode = 401 → [Telegram: AUTH EXPIRED alert] → Break
    ├─ Filter: error.statusCode >= 500 → [Data Store: DLQ] → Break
    └─ Default → [Set Variable: log] → Ignore
```

Access error details in expressions: `{{error.message}}`, `{{error.statusCode}}`, `{{error.bundle}}`

### Pattern D — Compensation Flow (Rollback Pattern)
Use when you cannot use Make.com's built-in Rollback (e.g., external APIs that have no rollback).

```
[Create Order] → [Charge Payment] → Error →
  [Cancel Order via API] → [Refund Payment via API] → [Telegram: CRITICAL] → Break
```

---

## 4. `iferror()` Function — Expression-Level Error Handling

Use `iferror()` for errors that can occur inside module field expressions (not module failures).

```
Safe number parse:    {{iferror(parseNumber(1.price; "."); 0)}}
Safe JSON parse:      {{iferror(parseJSON(1.body); toCollection("error"; "parse_failed"))}}
Safe array access:    {{iferror(get(1.items; 0).id; "no-item")}}
Safe divide:          {{iferror(divide(1.total; 1.count); 0)}}
```

`iferror` does NOT catch module-level errors — only expression evaluation errors.

---

## 5. Incomplete Executions

When a Break directive fires, Make.com stores the incomplete execution:
- **Retention:** 30 days
- **Access:** Scenario → History → Incomplete Executions
- **API access:** Use `mcp__claude_ai_Make__executions_list` with `status=incomplete`
- **Manual retry:** Available in UI or via `mcp__claude_ai_Make__scenarios_run` with `executionId`

**Gotcha:** Incomplete executions count against your plan's operation limits when retried. Monitor DLQ size to avoid bill spikes.

---

## 6. Error Information Available in Error Handler Route

| Variable | Content | Example |
|----------|---------|---------|
| `{{error.message}}` | Error message text | "Connection refused" |
| `{{error.name}}` | Error type name | "RuntimeError" |
| `{{error.statusCode}}` | HTTP status code | 429 |
| `{{error.headers}}` | Response headers object | Rate-limit headers |
| `{{error.bundle}}` | Full bundle at time of error | All module inputs |
| `{{error.meta}}` | Additional metadata | API-specific info |

---

## 7. Blueprint JSON Pattern for Error Handler Config

When creating scenarios programmatically via `mcp__claude_ai_Make__scenarios_create`, include error handler config in the module blueprint:

```json
{
  "id": 5,
  "module": "http:ActionSendData",
  "metadata": {
    "designer": { "x": 300, "y": 0 }
  },
  "parameters": { "... module params ..." },
  "routes": [
    {
      "name": "ErrorRoute",
      "flow": [
        {
          "id": 6,
          "module": "builtin:BasicFeeder",
          "metadata": { "directive": "break" }
        }
      ]
    }
  ]
}
```

Always validate with `mcp__claude_ai_Make__validate_blueprint_schema` before calling `scenarios_create`.

---

## 8. Audit Checklist — 8-Point Error Handling Review

Run this check for every scenario during `/audit`:

```
□ 1. Every HTTP/API module has retry enabled (max 2–3 retries, interval ≥ 10s)
□ 2. Every module that can fail has an explicit error handler route (not defaulting to halt)
□ 3. At least one path leads to a Telegram/SMS alert for non-trivial failures
□ 4. No error handler route uses "Ignore" on a module whose output is required downstream
□ 5. Transactional flows (payment, booking, inventory) use Rollback or compensation pattern
□ 6. No infinite error loops (error handler does not re-trigger the same failing module)
□ 7. DLQ data store exists if Break is used (so data is not silently lost)
□ 8. iferror() wraps any expression that parses external data (JSON, numbers, dates)
```

Report each as PASS / FAIL / N/A with the specific module name and a one-line fix recommendation.

---

## 9. Common Error Scenarios and Fixes

| Scenario | Root Cause | Fix |
|----------|-----------|-----|
| 429 Too Many Requests | Rate limit hit | Add retry with exponential backoff; reduce scenario frequency |
| 401 Unauthorized | Token expired | Re-authenticate connection; set up token refresh if API supports it |
| 500 from third-party | Service outage | Log to DLQ; alert; retry next day |
| Empty/null field breaks downstream | No null guard | Add `ifempty()` or `iferror()` expressions; add filter module |
| Incomplete execution builds up | Break fires too often | Review root cause; add resumable logic if errors are expected |
| Scenario halts with no log | No error handler on failing module | Add error handler with at minimum a log + alert |
| JSON parse fails | API changed response format | Add `iferror(parseJSON(...); ...)` and alert on fallback |
