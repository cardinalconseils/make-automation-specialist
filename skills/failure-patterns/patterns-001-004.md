# Failure Patterns 001–004

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
