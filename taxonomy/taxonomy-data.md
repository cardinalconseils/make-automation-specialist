# Taxonomy: Data Mapping / Bundle Errors

**Prefix:** `DATA-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### DATA-001 — Type Mismatch
- **Symptom:** "Expected number but got string" (or similar); downstream module rejects input
- **Root cause:** Field is text where number expected (or vice versa). Implicit coercion failed.
- **Fix:** `parseNumber({{x}})` for text→number. `toString({{x}})` for number→text. `parseDate({{x}}; "YYYY-MM-DD")` for dates.

### DATA-002 — Null / Empty Value
- **Symptom:** Module fails on empty input; "DataError" with missing field
- **Root cause:** Optional field not populated by source; upstream module returned no data for that field
- **Fix:** `ifempty({{x}}; "default")`. Add filter with `exists` operator before the failing module. Set defaults with Set Variable.

### DATA-003 — Array vs Single Value
- **Symptom:** Module expects single value but receives array (`[object Object]` in output); or expects array but gets single item
- **Root cause:** Source returns collection; no iterator used. Or `{{x}}` maps entire array object instead of `{{x.field}}`.
- **Fix:** Add Iterator module to normalize. Use `first({{array}})` or `last({{array}})` to extract one item. Add Array Aggregator to re-collect after iteration.

### DATA-004 — Date/Time Format Mismatch
- **Symptom:** "Invalid date" error; date filter fails; wrong date stored
- **Root cause:** Different services use different formats (ISO 8601, Unix timestamp, "YYYY-MM-DD", "MM/DD/YYYY"). Timezone not specified.
- **Fix:** `formatDate({{x}}; "YYYY-MM-DD"; "UTC")` — always specify format and timezone. Make uses UTC internally.

### DATA-005 — `[object Object]` in String Field
- **Symptom:** Output shows "[object Object]" literally
- **Root cause:** Mapping a collection/object where a string is expected (mapped `{{item}}` instead of `{{item.field}}`)
- **Fix:** Drill into the specific field: `{{item.field.subfield}}`. Use `toString({{item}})` only for debugging.

### DATA-006 — Null vs Empty String vs Missing Field
- **Symptom:** Filter comparing to "" passes when it shouldn't; `exists` check behaves unexpectedly
- **Root cause:** Make distinguishes three states: `null` (field exists, value is null), `""` (empty string), and missing (field not in bundle at all)
- **Fix:** Use `exists` operator in filters for "field is present". Use `!= ""` for non-empty string. Use `ifempty` to collapse null and "" into a default.

### DATA-007 — Schema Drift (Silent Break)
- **Symptom:** Mappings show empty pills (no error, but field is blank in output); downstream modules produce wrong results silently
- **Root cause:** Source API added, removed, or renamed a field after scenario was built. Old field path now returns nothing.
- **Fix:** Re-run "Determine data structure" on the source module. Re-map all affected downstream fields. Check for empty pills throughout.
