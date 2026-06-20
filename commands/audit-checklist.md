# /audit — Full Checklist and Scoring Criteria

Reference file for `commands/audit.md`.

## Audit Checklist

For each scenario, check every item below. Mark CRITICAL / WARNING / INFO.

### Reliability
- [ ] HTTP/API modules missing error handler → CRITICAL
- [ ] No retry logic on network-dependent modules → WARNING
- [ ] Trigger re-triggers itself (infinite loop risk) → CRITICAL
- [ ] Hard-coded credentials or API keys in module config → CRITICAL
- [ ] Unhandled null/empty data paths → WARNING

### Observability
- [ ] No error notification path (nothing alerts on failure) → CRITICAL
- [ ] No logging of key outcomes → WARNING
- [ ] No data validation before processing → WARNING

### Efficiency
- [ ] High operation count — modules that can be consolidated → WARNING
- [ ] Full record fetched when only one field needed → WARNING
- [ ] No filter module before expensive downstream operations → WARNING
- [ ] Polling trigger where webhook alternative exists → INFO
- [ ] Duplicate scenario doing the same work → WARNING

### Connections
- [ ] Verify each connection used is still active → CRITICAL if broken
- `make-cli connections verify --connection-id {id}` for each

### Compliance
Call compliance-scanner skill for each scenario.

## Report Format

```
AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date: {timestamp}
Scenarios analyzed: {n}

SUMMARY
  🔴 Critical issues: {n}    (fix immediately — automation may break)
  🟡 Warnings: {n}           (fix when possible — reduces risk)
  🔵 Info: {n}               (nice to have)

CRITICAL ISSUES
  [Scenario Name]
  Issue: {plain-language description}
  Why it matters: {impact if not fixed}
  Proposed fix: {what I will do, in plain language}
  Risk of fix: Low

WARNINGS
  ...

COMPLIANCE
  ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Fix Format

Each fix shown as:

```
FIX #{n}
Scenario: {name}
Issue: {short description}
What I'll change: {plain-language}
Risk: Low / Medium
Operations impact: {+/- n}/month
```
