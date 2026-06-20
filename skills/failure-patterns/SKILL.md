---
name: failure-patterns
description: "Cross-cutting Make.com failure patterns — schema drift, eventual consistency, webhook replay, timezone drift, missing pagination, fire-and-forget async, and incomplete execution queue leaks. Load when designing scenarios to prevent these patterns proactively."
allowed-tools: Read
---

# Make.com Failure Patterns — Cross-Cutting Reference

These patterns cut across multiple failure categories. Check against every scenario design.

See [patterns-001-004.md](patterns-001-004.md) for PATTERN-001 through PATTERN-004.
See [patterns-005-008.md](patterns-005-008.md) for PATTERN-005 through PATTERN-008.

---

## Pre-Build Checklist

Before building any scenario, check:
- [ ] Any operation >40s? → Need async pattern (PATTERN-006)
- [ ] High-frequency webhook? → Need dedupe (PATTERN-003)
- [ ] Writes to shared state? → Need idempotency or dedup
- [ ] List/collection processing? → Need pagination (PATTERN-005)
- [ ] Date comparisons? → UTC everywhere (PATTERN-004)
- [ ] External API calls? → Schema monitoring plan (PATTERN-001)
