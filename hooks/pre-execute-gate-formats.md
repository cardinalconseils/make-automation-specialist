# Pre-Execute Gate Formats

Display formats for each risk level. Load from `pre-execute.md`.

---

## LEVEL 1 Gate (reversible write)

Check if this exact action was already approved this turn. If yes, proceed.
If no, show gate:

```
APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What I'm about to do: {plain-language description}
Target: {resource name}
Type: {create / update / activate / deactivate}
Risk: Low — reversible

{Summary of changes if create or update}

Type "approve" to proceed, or tell me what to change.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Valid: "approve", "yes", "go ahead", "do it", "confirmed", "ok", "proceed", "build all", "run it"

---

## LEVEL 2 Gate (HIGH RISK — always show, even after batch approval)

```
HIGH-RISK ACTION — REVIEW CAREFULLY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
I am about to EXECUTE a live scenario. This may:
• Send real emails or messages to real people
• Write or delete real data in external systems
• Trigger charges or payments

Scenario: {name}
Last run: {date or "never"}
Estimated operations this run: ~{n}

Have you tested this with safe/test data first?

Type "run it" to execute, or tell me to stop.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Valid ONLY: "run it", "execute it", "yes run it"

---

## LEVEL 3 Gate (DESTRUCTIVE — never skip, batch approval excluded)

```
DESTRUCTIVE ACTION — CANNOT BE UNDONE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You are about to permanently delete:

  {Resource type}: {name}
  Created: {date}
  {Relevant stats}

Make.com has no recycle bin. This is permanent.

Type exactly: DELETE {resource name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After user types exact phrase → write approval token (see approval-token-protocol.md)
Any typo → re-show the gate. Any other approval phrase → rejected.
