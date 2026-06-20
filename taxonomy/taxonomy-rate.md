# Taxonomy: Rate Limit / Quota

**Prefix:** `RATE-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### RATE-001 — App-Side 429 (Target API)
- **Symptom:** `RateLimitError`; 429 from Google, Slack, Airtable, etc.
- **Root cause:** Scenario hitting target API faster than allowed quota
- **App-specific limits:**
  - Google Sheets: 60 reads/min per user; 300 reads/min per project
  - Airtable: 5 requests/sec per base
  - Slack: Tier 1 (1/min), Tier 2 (20/min), Tier 3 (50/min), Tier 4 (100+/min) per method
  - Telegram Bot API: 30 messages/sec overall; 1 msg/sec to same chat
- **Fix:** Add Sleep module between iterations. Use error handler → Break (retry with backoff). Batch operations where API supports bulk endpoints.

### RATE-002 — Make Operations Quota
- **Symptom:** "Your plan's operations limit has been reached"; scenario disabled
- **Root cause:** Monthly operation count exceeded for the Make plan
- **Plan limits (verify on Make pricing page — changes frequently):**
  - Core: ~10,000 ops/month
  - Pro: ~10,000 + add-ons
  - Teams: ~10,000 + add-ons
- **Fix:** Upgrade plan. Audit scenario for unnecessary operations (each module execution = 1 operation). Combine steps where possible. Wait for monthly reset.

### RATE-003 — Make Data Transfer Quota
- **Symptom:** Scenario soft-warns then hard-stops on data transfer
- **Root cause:** Monthly data transfer limit exceeded
- **Approximate limits:** Core ~5 GB, Pro ~20 GB, Teams ~70 GB
- **Fix:** Upgrade plan. Reduce payload sizes (pass IDs/URLs instead of binary content). Use streaming patterns.

### RATE-004 — Make Per-Connection Rate Cap
- **Symptom:** 429 or throttle from Make itself (not the target app), intermittent
- **Root cause:** Make's internal per-connection rate limiting
- **Fix:** Spread load across multiple connections to the same service. Reduce scenario frequency.
