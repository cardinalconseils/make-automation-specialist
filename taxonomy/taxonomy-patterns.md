# Taxonomy: Cross-Cutting Failure Patterns

**Prefix:** `PATTERN-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### PATTERN-001 — Schema Drift (Silent Break)
- **Description:** Source API changes its response schema (field renamed, added, removed). Old mappings silently return empty. No error raised.
- **Detection:** Scenario runs without error but output is blank or wrong. Empty pills in module config.
- **Fix:** Re-run "Determine data structure". Audit all field mappings. Set up monitoring on key output fields.

### PATTERN-002 — Eventual Consistency Race
- **Description:** Trigger fires before the source record is fully written. Follow-up "Get Record" returns 404 or partial data.
- **Example:** Stripe `payment_intent.created` webhook fires → Make immediately fetches customer → customer not yet propagated.
- **Fix:** Add Sleep 2-5 seconds after trigger before fetching. Or add error handler → Break (retry after delay).

### PATTERN-003 — Webhook Replay Without Dedupe
- **Description:** Webhook sent multiple times (retry logic in sender), scenario processes duplicate payload → duplicate records created.
- **Fix:** Implement data store dedupe: store unique event ID (webhook ID, transaction ID), check on each run, skip if already processed.

### PATTERN-004 — Timezone Mismatch
- **Description:** Make uses UTC internally. Source app uses local time. Date filters, comparisons, and schedule triggers drift by timezone offset.
- **Fix:** Always use UTC in Make. Convert source timestamps with `parseDate({{x}}; "YYYY-MM-DDTHH:mm:ssZ")` before comparison. Schedule in UTC.

### PATTERN-005 — Pagination Missing
- **Description:** Search module returns only first page. Subsequent pages silently ignored. Data appears correct but is incomplete.
- **Fix:** Add iterator with cursor/offset. Loop until `next_cursor` is empty or result count < page size.

### PATTERN-006 — Fire-and-Forget for Long Operations
- **Description:** Any operation >40s (video generation, large export, batch processing) will timeout in synchronous execution.
- **Pattern:** Scenario A: receive trigger → validate → HTTP POST to Scenario B webhook (fire-and-forget, `parseResponse: false`) → return immediately. Scenario B: webhook → do the long work → notify user when complete.
- **Used for:** Vertex AI video generation, large file processing, bulk exports.

### PATTERN-007 — Incomplete Execution Queue Leak
- **Description:** Scenarios fail with error handler → Break, queuing incomplete executions. Queue fills → ops consumed toward plan quota → plan cap hit prematurely.
- **Fix:** Monitor incomplete executions count. Clear queue regularly. Fix root cause so Break is not needed long-term.

### PATTERN-008 — Shared OAuth App Throttle
- **Description:** Make's shared OAuth apps for Google/Microsoft hit global rate caps across all Make users. Causes intermittent 429/403 even at low personal usage.
- **Fix:** Register your own OAuth app (Google Console, Azure), configure in Make as "Custom App" connection.
