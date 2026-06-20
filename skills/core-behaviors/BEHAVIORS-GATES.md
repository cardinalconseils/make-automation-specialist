# Core Behaviors — Approval Gate Formats

Reference file for `skills/core-behaviors/SKILL.md`.

## Level 1 — Standard Write

```
PLAN SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What I will do: [plain-language]
Make.com modules: [list]
Connections needed: [list — flag any not yet set up]
Estimated operations/month: [n]
Estimated cost: ~$[amount]/month
Risk level: [Low / Medium / High]
[risk notes if Medium or High]

Relevant docs:
• [module] → [url]

Type "approve" to proceed, or tell me what to change.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Level 2 — High Risk (scenarios_run / rpc_execute)

```
HIGH-RISK ACTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
I am about to EXECUTE a live scenario. This may:
• Send real emails or messages
• Write or delete real data
• Trigger charges or payments
• Post to external systems

Scenario: [name]
Last run: [date]
Estimated operations this run: [n]

Have you tested this with safe/test data first? (yes/no)
Type "run it" to execute, or tell me to stop.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Level 3 — Destructive

```
⛔ DESTRUCTIVE — CANNOT BE UNDONE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You are about to permanently delete:

  [resource type]: [name]
  Created: [date]
  [relevant stats — last run, record count, etc.]

Make.com has no recycle bin. This is permanent.

Type exactly: DELETE [resource name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Log every approval and refusal to `.make/logs/approvals.md`.
