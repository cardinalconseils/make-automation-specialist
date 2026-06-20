# Taxonomy: Iterator / Aggregator

**Prefix:** `ITER-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### ITER-001 — Iterator Over Empty Array
- **Symptom:** Iterator produces zero cycles; aggregator emits empty; downstream skipped silently
- **Root cause:** Source array is empty (zero records from search, empty API response)
- **Fix:** Add a filter after the source module checking `length({{array}}) > 0` before the iterator. Or handle empty output downstream with a fallback.

### ITER-002 — Wrong Aggregator Source Module
- **Symptom:** Aggregator outputs only 1 bundle regardless of iterator cycles
- **Root cause:** Aggregator's "Source Module" is set to the wrong module (not the iterator)
- **Fix:** Open aggregator settings → set "Source Module" to the iterator (or the trigger if iterating bundles).

### ITER-003 — Nested Iterators Cross-Linked
- **Symptom:** Inner aggregator consuming outer iterator's bundles, or vice versa
- **Root cause:** Inner aggregator "Source Module" pointing to outer iterator
- **Fix:** Inner aggregator must target inner iterator. Outer aggregator must target outer iterator. Draw the nesting explicitly before building.

### ITER-004 — Wrong Aggregator Type
- **Symptom:** Type errors in aggregator; coerce errors
- **Root cause:** Array Aggregator used where Text Aggregator needed (or vice versa)
- **Fix:** Array Aggregator → for collecting items into an array. Text Aggregator → for joining strings. Numeric Aggregator → for sum/min/max/average.

### ITER-005 — Bundle Order Not Guaranteed
- **Symptom:** Output order inconsistent across runs
- **Root cause:** Make does not guarantee bundle order when coming from parallel paths
- **Fix:** Sort output after aggregation if order matters.
