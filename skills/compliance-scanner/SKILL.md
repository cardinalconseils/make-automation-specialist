---
name: compliance-scanner
description: Surface-level compliance risk assessment for Make.com scenarios. Checks GDPR, Quebec Law 25, PCI-DSS, and HIPAA. NOT legal advice — flags risks for human review.
---

# Skill: compliance-scanner

Performs surface-level compliance risk assessment on Make.com scenarios.
NOT legal advice. Flags risks for human review.

## When to Run

- During audit (scenario-auditor calls this per scenario)
- On demand when user asks "is this compliant?"
- Automatically when scenario-reader detects personal/payment/health data

## Frameworks Assessed

See [frameworks.md](frameworks.md) for the full checklist for each framework (GDPR, Quebec Law 25, PCI-DSS, HIPAA).

## Output Format

```markdown
## Compliance Surface Assessment

**Frameworks assessed:** {list}
**Assessment date:** {timestamp}
**Status:** {risks-found | clean}

### Risks Found

#### [RISK TITLE]
**Framework:** {GDPR / Quebec Law 25 / PCI-DSS / HIPAA}
**Severity:** {Critical / High / Medium / Low}
**Scenario:** {scenario name}
**Description:** {plain-language risk description}
**Recommendation:** {specific action to take}
**References:** {relevant article/section}

### Clean Areas
{What was assessed and found compliant}

---
**Disclaimer:** This assessment is a surface-level automated scan, not legal advice.
Consult a qualified privacy lawyer before making compliance decisions.
In Quebec: contact Commission d'accès à l'information for guidance.
In the EU: contact your Data Protection Officer (DPO) or national supervisory authority.
```

## Severity Definitions

**Critical:** Likely violation in progress. Stop and fix before next run.
Example: Payment card numbers flowing through Make.com logs.

**High:** Probable violation if not addressed within 30 days.
Example: Personal data transferred to US service without standard contractual clauses.

**Medium:** Risk area — review and document mitigation.
Example: No documented legal basis for processing marketing email data.

**Low:** Best practice not followed — low immediate risk.
Example: No explicit data retention policy defined for this automation's data.

## Save Output

Save to `.make/compliance/{timestamp}-{scenario-id}-compliance.md`.
Append summary to workspace-level compliance overview at `.make/compliance/overview.md`.
