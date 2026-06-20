# Taxonomy: Make Engine Error Types

**Prefix:** `MAKE-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### MAKE-DATA — DataError
- **Symptom:** "DataError" in execution log; module stops; missing required field
- **Root cause:** Required field in bundle is null/empty, field path wrong
- **Fix:** Add Set Variable defaults upstream. Filter null bundles with filter (`exists` operator). Use `ifempty({{x}}; "default")`.

### MAKE-INCONSIST — InconsistencyError
- **Symptom:** "InconsistencyError"; bundle shape changed mid-scenario
- **Root cause:** Source API changed its response schema; array became object or vice versa
- **Fix:** Re-run "Determine data structure" on the trigger/source module. Re-map all downstream field references.

### MAKE-DUP — DuplicateDataError
- **Symptom:** Records created twice; "DuplicateDataError"
- **Root cause:** Webhook replay, duplicate trigger fire, scenario retried after partial success
- **Fix:** Implement data store dedupe: store processed ID, check on each run, skip if seen.

### MAKE-RUNTIME — RuntimeError
- **Symptom:** Generic "RuntimeError" with no specific app error nested
- **Root cause:** Various — check the execution detail log for the nested message
- **Fix:** Expand the error in scenario history → inspect full error object. Often reveals the real cause (usually a specific HTTP or data error underneath).

### MAKE-INCOMPLETE — IncompleteDataError
- **Symptom:** Trigger ran but bundle is partial; downstream module sees missing fields
- **Root cause:** Source record not fully written when trigger fired (eventual consistency)
- **Fix:** Add Sleep 2-5 seconds after trigger. Then re-fetch the record by ID.

### MAKE-MAXRESULTS — MaxResultsExceededError
- **Symptom:** Search module returns partial results or errors on large datasets
- **Root cause:** Query returns more records than module limit
- **Fix:** Paginate with iterator and cursor. Use "Limit" and "Offset" parameters iteratively.

### MAKE-FILESIZE — MaxFileSizeExceededError
- **Symptom:** File processing fails; "file too large"
- **Root cause:** File exceeds 100 MB (Core plan) or plan-specific limit
- **Fix:** Stream/split the file, or pass a cloud storage URL (GCS, S3, Drive) instead of the binary content.
