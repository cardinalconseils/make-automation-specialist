# Taxonomy: Blueprint / Schema Errors

**Prefix:** `BLUEPRINT-`
**Index:** [make-failure-taxonomy.md](make-failure-taxonomy.md)

---

### BLUEPRINT-001 — `isinvalid: true` on API Push
- **Symptom:** Make API returns `"isinvalid": true` on scenario update; scenario broken after push
- **Root cause:** Blueprint JSON has structural errors: invalid module IDs in flow/route references, missing connection IDs, bad field references, malformed mapper expressions
- **Fix:** Check all `"id"` references in `flow` and `routes` arrays match actual module IDs. Verify all connection IDs exist (`GET /api/v2/connections`). Validate JSON structure. Push incrementally — one change at a time to isolate.

### BLUEPRINT-002 — Connection ID Not Found in Target Account
- **Symptom:** Module shows as "disconnected" or red after blueprint push; connection picker empty
- **Root cause:** Blueprint references a connection ID that belongs to a different Make account or has been deleted
- **Fix:** Get valid connection IDs: `GET /api/v2/connections?teamId={teamId}`. Replace all old connection IDs in blueprint with the correct ones for the target account.

### BLUEPRINT-003 — Broken Field Reference After Module ID Change
- **Symptom:** Fields show `{{undefined}}` or mapping lost; downstream modules have empty pills after push
- **Root cause:** Blueprint edit changed a module's `id`; all mapper expressions referencing `{{oldId.field}}` are now broken
- **Fix:** Before changing any module ID, grep the entire blueprint JSON for the old ID and update all references. Pattern: `{{moduleId.field}}` where `moduleId` is the integer or string ID.

### BLUEPRINT-004 — Mapper Expression Syntax Error
- **Symptom:** Module shows error in visual editor; expression not evaluated
- **Root cause:** Invalid Make formula syntax in mapper field
- **Fix:** Test expressions in Make's formula builder. Common issues: unclosed parentheses, wrong function name, using JS syntax instead of Make functions (`if()` not `? :`).
