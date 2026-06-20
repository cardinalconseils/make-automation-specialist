# Scenario Auditor — Checklist, Report, Fix Flow, and Changelog

Continuation of `agents/scenario-auditor.md`. Steps 1 and 2 are in the entry file.

---

## Step 3 — Analyze

**Errors and Reliability**
- [ ] Missing error handlers on modules that can fail (HTTP, API calls, file ops)
- [ ] No retry logic on network-dependent modules
- [ ] Infinite loop risk (triggers that re-trigger themselves)
- [ ] Hard-coded credentials or API keys in module configs
- [ ] Unhandled empty/null data paths

**Efficiency**
- [ ] High operation count — modules that could be consolidated
- [ ] Missing filters before expensive operations
- [ ] Polling-based triggers where webhooks exist as alternative

**Observability**
- [ ] No error notification path (nothing alerts when it breaks)
- [ ] No logging of key outcomes
- [ ] No data validation before processing

**Error Handling** — run full 8-point checklist from `skills/error-handler/SKILL.md` Section 8.
Report each point as PASS / FAIL / N/A with module name and one-line fix.

**Failure Pattern Scan** — classify each issue via taxonomy: "This matches `CODE — Title`".
Never describe an issue without a taxonomy code. Flag unmatched patterns for taxonomy-curator.

**Cross-Cutting Patterns** — check PATTERN-001 through PATTERN-008. Flag matches in Warning/Critical.

**Compliance** — call compliance-scanner skill for each scenario.

## Step 4 — Report

Save to `.make/audits/{timestamp}-audit.md`. Generate Mermaid diagrams for scenarios with issues
(via diagram-generator skill) to `.make/diagrams/`.

Report structure: header (scope/date/count), summary counts (Critical/Warnings/Info/Compliant),
Critical Issues (scenario name, plain-language issue, why it matters, proposed fix, risk level),
Warnings section, Info section, Compliance Surface.

## Step 5 — Fix Proposal

Present grouped fix plan. Approval options:
- "Fix all critical issues" → one approval for the critical batch
- "Fix all warnings too" → one approval for critical + warning batch
- "Let me choose" → step through each fix individually

Each fix shown as:
```
FIX: [Issue short name]
Scenario: [Name]
What I'll change: [plain-language description]
Risk: [Low / Medium]
Operations impact: [+/- N operations/month]
```

## Step 6 — Execute Fixes

After approval:
1. Run `blueprint-review` skill on updated blueprint JSON — do not push if blockers remain
2. Apply fixes via Make.com MCP (narrate each change)
3. Write changelog entry to `.make/changelog/{scenario-id}.md`
4. Re-fetch blueprint and confirm `isinvalid: false`
5. If a fix fails: load `failure-diagnostician` → classify → fix → retry once
6. Report outcome

## Step 7 — Post-Audit Debrief

1. "Fixed N critical issues, N warnings across N scenarios."
2. List remaining unfixed items with explanation
3. Recommend next audit date
4. Remind about Telegram alerts being active

## Bulk Audit Progress Format

```
Analyzing workspace scenarios...
[████████░░] 8/12 — Currently: Stripe Payment Sync
```

## Fix Changelog Format

Append to `.make/changelog/{scenario-id}.md`:

```markdown
## {timestamp} — {change-type}
**Changed by:** Claude (scenario-auditor)
**Approved by:** User (session {date})
**Issue:** {description}

**Before:** {relevant before state in plain language + JSON snippet}
**After:** {relevant after state in plain language + JSON snippet}
**Outcome:** {success / failed + error}
```
