# Taxonomy: Trigger / Scheduling Failures

**Prefix:** `TRIG-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### TRIG-001 — Webhook Not Receiving Data
- **Symptom:** Scenario never triggers; no incoming data in webhook history
- **Root cause:** Wrong webhook URL pasted into external service; webhook not saved; Make scenario inactive
- **Fix:** Copy webhook URL fresh from Make module. Paste into external service and save. Verify scenario is active. Test with a manual trigger/test call.

### TRIG-002 — Scheduled Run Missed
- **Symptom:** Scenario didn't run at expected time
- **Root cause:** Scenario was paused; Make maintenance window; timezone mismatch in schedule config; previous run still executing when next slot hit
- **Fix:** Verify scenario is active (not paused). Use UTC in scheduling. Enable "Sequential processing" only if runs must not overlap. Check if scenario auto-disabled after consecutive failures.

### TRIG-003 — Polling Trigger Set to "Scheduled" Instead of "Immediately"
- **Symptom:** Webhook data piles up; processing delayed; queue grows
- **Root cause:** Scenario scheduling set to "Run on schedule" instead of "Run immediately as data arrives"
- **Fix:** Scenario settings → Scheduling → set to "Run immediately as data arrives" (instant trigger mode).

### TRIG-004 — Webhook Queue Overflow
- **Symptom:** Webhooks start dropping after >10,000 pending
- **Root cause:** Scenario processing too slow for incoming webhook rate; queue maxes out
- **Fix:** Simplify scenario to reduce execution time. Add a "Router + immediate ack" pattern: webhook → immediately return 200, push to queue/datastore → separate scenario processes async.

### TRIG-005 — Wrong Epoch on First Activation
- **Symptom:** Scenario reprocesses old records on first run, or misses recent ones
- **Root cause:** "Choose where to start" epoch set incorrectly on polling trigger activation
- **Fix:** On first activation, use "Choose where to start" and set to "From now on" (or specific timestamp) to avoid reprocessing history.

### TRIG-006 — Scenario Auto-Disabled After Consecutive Failures
- **Symptom:** Scenario shows as "inactive"; was working before
- **Root cause:** Make auto-disables a scenario after N consecutive full-failure cycles (default threshold ~3)
- **Fix:** Fix the root cause of failures. Re-enable scenario. Optionally raise failure tolerance in scenario settings or add error handlers to prevent full-cycle failures.

### TRIG-007 — Daylight Saving Time Drift
- **Symptom:** Scheduled scenario runs 1 hour early or late after clocks change
- **Root cause:** Cron schedule set in local time; DST shift not accounted for
- **Fix:** Always set schedules in UTC. UTC does not observe DST.
