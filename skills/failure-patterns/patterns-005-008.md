# Failure Patterns 005–008

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
