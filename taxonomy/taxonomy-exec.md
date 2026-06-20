# Taxonomy: Execution Limits

**Prefix:** `EXEC-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### EXEC-001 — 40-Second HTTP Timeout
- **Symptom:** HTTP module times out; long-running API calls fail
- **Root cause:** Make's default HTTP module timeout is 40 seconds. Long operations (video generation, large file processing) exceed this.
- **Fix:** Raise HTTP module timeout in advanced settings (max 300s). For operations >300s: use async pattern — fire-and-forget HTTP POST to a separate webhook scenario, return immediately, let the separate scenario handle the long operation and notify when done.

### EXEC-002 — 40-Minute Scenario Execution Limit
- **Symptom:** Scenario times out mid-execution on large iterators
- **Root cause:** Scenario has run for 40 minutes total
- **Fix:** Split into "mini scenarios" chained via webhooks. Use pagination with state stored in a data store.

### EXEC-003 — No Error Handler — Cascade Failure
- **Symptom:** One module failure stops the entire scenario
- **Root cause:** No error handler on the failing module; default behavior is halt
- **Fix:** Right-click the module → "Add error handler" → choose: Resume (continue with fallback), Ignore (skip and continue), Break (retry later), Rollback (undo), Commit (force commit partial state).

### EXEC-004 — Incomplete Executions Queue
- **Symptom:** Operations consumed faster than expected; "Incomplete executions" count growing
- **Root cause:** Scenarios failing but not erroring cleanly — each incomplete execution consumes ops toward quota
- **Fix:** Add error handlers to fail fast cleanly. Clear the incomplete executions queue. Fix root cause to prevent accumulation.

### EXEC-005 — Parallel Execution Race Condition
- **Symptom:** Duplicate records, wrong order, state corruption in data store
- **Root cause:** "Allow parallel executions" enabled with non-idempotent operations
- **Fix:** Disable parallel executions for scenarios that write to shared state. Or make all writes idempotent (upsert by key, not create).
