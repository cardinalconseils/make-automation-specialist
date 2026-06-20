# Taxonomy: Router / Filter Logic

**Prefix:** `ROUTER-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### ROUTER-001 — First-Match Route Order
- **Symptom:** Wrong route taken; more specific condition should win but doesn't
- **Root cause:** Make router takes the **first matching route** — order matters. A broad condition before a specific one catches everything.
- **Fix:** Reorder routes — most specific conditions first, fallback/catch-all last.

### ROUTER-002 — No Fallback Route
- **Symptom:** Bundles silently lost when no route condition matches; no error raised
- **Root cause:** Router has no "else"/fallback route
- **Fix:** Add a final route with no filter condition as catch-all. Log or alert in this route for unexpected cases.

### ROUTER-003 — Filter Always False
- **Symptom:** Nothing passes through a filter; scenario ends early with no output
- **Root cause:** Filter condition never true — wrong field reference, type mismatch in comparison, blank operand
- **Fix:** Temporarily disable the filter to confirm data flows. Enable "Dev Tools" in Make to inspect bundle values. Check comparison types (string "5" vs number 5).

### ROUTER-004 — AND/OR Logic Grouping Confusion
- **Symptom:** Filter passes cases it shouldn't, or blocks cases it should pass
- **Root cause:** Make filter groups: OR conditions on same row, AND between rows. Easy to misconfigure.
- **Fix:** Re-read filter as: `(row1_cond1 OR row1_cond2) AND (row2_cond1 OR row2_cond2)`. Restructure rows to match intended logic.

### ROUTER-005 — Type Coercion in Filter
- **Symptom:** `"05" == 5` unexpectedly false; `"5" == 5` true — inconsistent behavior
- **Root cause:** Make does some implicit coercions but not all
- **Fix:** Normalize values before comparison. Use `parseNumber()` or `toString()` to make types explicit in filter operands.
