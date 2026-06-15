---
name: failure-patterns
description: "Cross-cutting Make.com failure patterns — schema drift, eventual consistency, webhook replay, timezone drift, missing pagination, fire-and-forget async, and incomplete execution queue leaks. Load when designing scenarios to prevent these patterns proactively."
allowed-tools: Read
---

# Make.com Failure Patterns — Cross-Cutting Reference

These patterns cut across multiple failure categories. Check against every scenario design.

---

## PATTERN-001 — Schema Drift (Silent Break)

**What:** Source API changes its response schema. Old field mappings silently return empty. No error raised.

**Detection:** Scenario runs without error, but outputs are blank or wrong. Empty pills appear in module config when you open it.

**Prevent:**
- Add monitoring on key output fields (filter that alerts if blank)
- Use "Determine data structure" periodically to detect schema changes
- Document expected schema in `.make/plans/`

---

## PATTERN-002 — Eventual Consistency Race

**What:** Trigger fires before source record is fully written. Follow-up "Get Record" returns 404 or partial data.

**Example:** Stripe `payment_intent.created` → immediate customer fetch → customer not yet propagated.

**Prevent:** Add Sleep 2-5s after trigger. Or: error handler → Break (retry after delay).

---

## PATTERN-003 — Webhook Replay Without Dedupe

**What:** Webhook sent multiple times (sender retry logic). Scenario processes duplicate → duplicate records.

**Prevent:**
1. Add data store with unique event ID as key
2. On each run: check if ID exists → skip if seen, process if new, store ID after processing

---

## PATTERN-004 — Timezone Mismatch

**What:** Make uses UTC internally. Source app uses local time. Date filters and schedules drift by timezone offset.

**Prevent:**
- Always schedule in UTC
- Convert timestamps: `parseDate({{x}}; "YYYY-MM-DDTHH:mm:ssZ")`
- Store and compare dates in UTC

---

## PATTERN-005 — Missing Pagination

**What:** Search module returns only first page. Remaining pages silently ignored. Data appears correct but is incomplete.

**Detect:** Output count is always exactly the page size limit.

**Prevent:**
- Add cursor/offset iterator
- Loop until `next_cursor` is empty or result count < page size

---

## PATTERN-006 — Fire-and-Forget for Long Operations

**What:** Operations >40s (video generation, large export, bulk processing) timeout in synchronous execution.

**Pattern:**
```
Scenario A (fast):
  trigger → validate → HTTP POST to Scenario B webhook
  (parseResponse: false — fire-and-forget, don't wait for response)
  → return immediately to user

Scenario B (async):
  webhook → do long operation → notify user when complete
```

**When required:** Vertex AI Veo video, large file processing, bulk operations, any API with >40s latency.

---

## PATTERN-007 — Incomplete Execution Queue Leak

**What:** Break directive fires repeatedly → incomplete executions queue fills → ops consumed toward plan quota → plan cap hit prematurely.

**Detect:** `Incomplete executions` count grows steadily in scenario history.

**Prevent:**
- Fix root cause so Break fires rarely
- Clear incomplete executions queue regularly
- Add monitoring: alert when incomplete count > threshold

---

## PATTERN-008 — Shared OAuth App Throttle

**What:** Make's shared OAuth apps (Google, Microsoft) hit global rate caps across all Make users. Causes intermittent 429/403 even at low personal usage.

**Detect:** Intermittent auth failures with no change on your end.

**Prevent:** Register your own OAuth app:
- Google: console.cloud.google.com → APIs & Services → Credentials
- Microsoft: portal.azure.com → App registrations
Configure in Make → Connections → "Custom App"

---

## Pre-Build Checklist

Before building any scenario, check:
- [ ] Any operation >40s? → Need async pattern (PATTERN-006)
- [ ] High-frequency webhook? → Need dedupe (PATTERN-003)
- [ ] Writes to shared state? → Need idempotency or dedup
- [ ] List/collection processing? → Need pagination (PATTERN-005)
- [ ] Date comparisons? → UTC everywhere (PATTERN-004)
- [ ] External API calls? → Schema monitoring plan (PATTERN-001)
