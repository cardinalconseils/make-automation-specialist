# Error Handler Directives

## 1. Error Handler Route Types

Every module can have an error handler route. Make.com evaluates the route and takes one of five directives:

| Directive | What It Does | When to Use |
|-----------|-------------|-------------|
| **Resume** | Marks error as handled; continues from next module as if no error occurred | Non-critical data; partial success is acceptable (e.g., skip a bad row and continue) |
| **Rollback** | Rolls back the current execution; marks as incomplete; stops | Transactional workflows where partial execution is worse than no execution |
| **Ignore** | Ignores the error; continues with the **same** module's output being empty | Only when the module's output is truly optional and empty is fine |
| **Break** | Stops execution; saves incomplete execution for manual review (30-day retention) | When human review is required before retrying |
| **Commit** | Commits all operations so far; stops the rest of the scenario | After a critical operation that must persist even if later steps fail |

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

## 2. Error Variables Available in Handler Route

| Variable | Content | Example |
|----------|---------|---------|
| `{{error.message}}` | Error message text | "Connection refused" |
| `{{error.name}}` | Error type name | "RuntimeError" |
| `{{error.statusCode}}` | HTTP status code | 429 |
| `{{error.headers}}` | Response headers object | Rate-limit headers |
| `{{error.bundle}}` | Full bundle at time of error | All module inputs |
| `{{error.meta}}` | Additional metadata | API-specific info |

---

## 3. `iferror()` — Expression-Level Error Handling

Use `iferror()` for errors inside module field expressions (not module failures).

```
Safe number parse:    {{iferror(parseNumber(1.price; "."); 0)}}
Safe JSON parse:      {{iferror(parseJSON(1.body); toCollection("error"; "parse_failed"))}}
Safe array access:    {{iferror(get(1.items; 0).id; "no-item")}}
Safe divide:          {{iferror(divide(1.total; 1.count); 0)}}
```

`iferror` does NOT catch module-level errors — only expression evaluation errors.

---

## 4. Incomplete Executions (Break Directive)

When a Break directive fires:
- **Retention:** 30 days
- **Access:** Scenario → History → Incomplete Executions
- **API access:** `mcp__claude_ai_Make__executions_list` with `status=incomplete`
- **Manual retry:** UI or `mcp__claude_ai_Make__scenarios_run` with `executionId`

**Gotcha:** Incomplete executions count against plan operation limits when retried.
Monitor DLQ size to avoid bill spikes.

---

## 5. Common Error Scenarios and Fixes

| Scenario | Root Cause | Fix |
|----------|-----------|-----|
| 429 Too Many Requests | Rate limit hit | Add retry with exponential backoff; reduce scenario frequency |
| 401 Unauthorized | Token expired | Re-authenticate connection; set up token refresh if supported |
| 500 from third-party | Service outage | Log to DLQ; alert; retry next day |
| Empty/null field breaks downstream | No null guard | Add `ifempty()` or `iferror()` expressions; add filter module |
| Incomplete execution builds up | Break fires too often | Review root cause; add resumable logic if errors are expected |
| Scenario halts with no log | No error handler on failing module | Add error handler with at minimum a log + alert |
| JSON parse fails | API changed response format | Add `iferror(parseJSON(...); ...)` and alert on fallback |
