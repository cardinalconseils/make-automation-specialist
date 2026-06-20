# Make.com Failure Taxonomy
**Version:** 1.0 — 2026-06-15
**Status:** Living document — update via `/make-taxonomy-update` skill
**Source:** Make.com docs + community forum + r/integromat + Academy + research corpus

---

## How to Use This Taxonomy

When diagnosing a failure:
1. Match symptom to a category header
2. Find the specific pattern code (e.g., `HTTP-429`)
3. Confirm root cause matches
4. Apply the fix
5. If pattern is new → add it here via `make-taxonomy-update` skill

---

## Category Index

| Code Prefix | Category | File |
|-------------|----------|------|
| `HTTP-` | HTTP Error Codes | [taxonomy-http.md](taxonomy-http.md) |
| `MAKE-` | Make Engine Errors | [taxonomy-make-engine.md](taxonomy-make-engine.md) |
| `CONN-` | Connection / OAuth Failures | [taxonomy-conn.md](taxonomy-conn.md) |
| `DATA-` | Data Mapping / Bundle Errors | [taxonomy-data.md](taxonomy-data.md) |
| `TRIG-` | Trigger / Scheduling Failures | [taxonomy-trig.md](taxonomy-trig.md) |
| `RATE-` | Rate Limit / Quota | [taxonomy-rate.md](taxonomy-rate.md) |
| `EXEC-` | Execution Limits | [taxonomy-exec.md](taxonomy-exec.md) |
| `ROUTER-` | Router / Filter Logic | [taxonomy-router.md](taxonomy-router.md) |
| `ITER-` | Iterator / Aggregator | [taxonomy-iter.md](taxonomy-iter.md) |
| `BLUEPRINT-` | Blueprint / Schema | [taxonomy-blueprint.md](taxonomy-blueprint.md) |
| `APP-GSHEETS-`, `APP-GMAIL-` | Google App Errors | [taxonomy-app-google.md](taxonomy-app-google.md) |
| `APP-TELEGRAM-`, `APP-SLACK-` | Messaging App Errors | [taxonomy-app-messaging.md](taxonomy-app-messaging.md) |
| `APP-AIRTABLE-`, `APP-STRIPE-`, `APP-VERTEXAI-` | Other App Errors | [taxonomy-app-other.md](taxonomy-app-other.md) |
| `PATTERN-` | Cross-Cutting Failure Patterns | [taxonomy-patterns.md](taxonomy-patterns.md) |

---

## Error Handler Reference

| Directive | Behavior | Use When |
|-----------|----------|----------|
| `Resume` | Continue with fallback bundle | You have a safe default to use when module fails |
| `Ignore` | Skip module, continue scenario | Module failure is acceptable, data loss OK |
| `Break` | Pause execution, retry later | Transient failure (429, 503) — want automatic retry |
| `Rollback` | Undo transactional operations, halt | Must ensure atomicity (financial, data integrity) |
| `Commit` | Force-commit partial state, halt cleanly | Partial progress should be saved even on failure |

**Default (no handler):** Scenario halts, logs error, counts toward auto-disable threshold.

---

## Taxonomy Changelog

| Date | Change | Source |
|------|--------|--------|
| 2026-06-15 | v1.0 — Initial draft | Research corpus + Make docs + community forum |
| 2026-06-20 | Split into per-category files (≤100 lines each) | File length rule enforcement |
