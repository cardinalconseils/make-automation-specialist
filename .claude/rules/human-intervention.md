# Human Intervention Rules

Three mandatory formats for messages requiring human attention.

---

## 1. Action Required

Use when the user **must** perform a manual step Claude cannot do.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    [exact command or step]
Why:    [one-line reason]
Then:   [what to tell Claude or do next]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Triggers: authorizing a Make.com connection in the browser, copying a webhook URL,
pasting an API key, manually testing a scenario run, upgrading a Make.com plan.

Rules:
- `Run:` field must be copy-pasteable — no `<placeholder>` values
- `Then:` must say exactly what to do or say next
- Multi-step sequences: one block per step, in order

---

## 2. Decision Required

Use when Claude **cannot proceed** without the user choosing.

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
[One sentence: what needs deciding and why it matters]

  1. [Option A] — [one-line consequence]
  2. [Option B] — [one-line consequence]

Recommended: [number] — [one sentence explaining why]

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

Triggers: trigger type choice (webhook vs polling), data structure decision,
approval before any Make.com write operation, activation vs. draft save.

Rules:
- Maximum 4 options — pre-filter to realistic ones
- Always include free-text escape ("describe what you want")
- `Recommended:` line is mandatory

---

## 3. Suggestion

Use for optional recommendations the user can ignore.

```
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
[The suggestion, 1–3 lines]
· · · · · · · · · · · · · · · · · · · · · · · ·
```

Rules:
- Never use for blocking situations — use Action Required or Decision Required
- One suggestion per block
