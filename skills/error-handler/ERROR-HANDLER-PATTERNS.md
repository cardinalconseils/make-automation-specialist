# Error Handler Architecture Patterns

## Pattern A — Log + Alert + Continue
Use for non-critical modules where partial data loss is acceptable.
```
[Module] → Error → [Set Variable: log entry] → [HTTP: log endpoint] → [Telegram: alert] → Resume
```

## Pattern B — Dead Letter Queue
Use for important data that must not be lost but can be retried later.
```
[Module] → Error → [Data Store: record with payload + error] → [Telegram: DLQ count] → Break
```
Schedule a separate scenario to retry DLQ records daily.

## Pattern C — Router by Error Code
Use for APIs that return predictable error codes with different remediation.
```
[Module] → Error →
  [Router]
    ├─ Filter: error.statusCode = 429 → [Tools: Sleep 60s] → Resume
    ├─ Filter: error.statusCode = 401 → [Telegram: AUTH EXPIRED] → Break
    ├─ Filter: error.statusCode >= 500 → [Data Store: DLQ] → Break
    └─ Default → [Set Variable: log] → Ignore
```
Access error details: `{{error.message}}`, `{{error.statusCode}}`, `{{error.bundle}}`

## Pattern D — Compensation Flow (Rollback Pattern)
Use when Make.com's built-in Rollback is unavailable (external APIs).
```
[Create Order] → [Charge Payment] → Error →
  [Cancel Order via API] → [Refund Payment via API] → [Telegram: CRITICAL] → Break
```

---

## Blueprint JSON for Error Handler Config

```json
{
  "id": 5,
  "module": "http:ActionSendData",
  "parameters": { "... module params ..." },
  "routes": [
    {
      "name": "ErrorRoute",
      "flow": [
        { "id": 6, "module": "builtin:BasicFeeder",
          "metadata": { "directive": "break" } }
      ]
    }
  ]
}
```

Always validate with `mcp__claude_ai_Make__validate_blueprint_schema` before `scenarios_create`.

---

## Audit Checklist — 8-Point Error Handling Review

Run for every scenario during `/audit`:

```
□ 1. Every HTTP/API module has retry enabled (max 2–3 retries, interval ≥ 10s)
□ 2. Every module that can fail has an explicit error handler route
□ 3. At least one path leads to a Telegram/SMS alert for non-trivial failures
□ 4. No "Ignore" on a module whose output is required downstream
□ 5. Transactional flows use Rollback or compensation pattern
□ 6. No infinite error loops (handler doesn't re-trigger the same module)
□ 7. DLQ data store exists if Break is used (data not silently lost)
□ 8. iferror() wraps any expression parsing external data (JSON, numbers, dates)
```

Report each as PASS / FAIL / N/A with module name and one-line fix.
