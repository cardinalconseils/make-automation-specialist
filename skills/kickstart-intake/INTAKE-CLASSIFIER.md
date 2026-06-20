# Intake: Complexity Classifier & Priority Ranker

Part of `kickstart-intake`. Called from `INTAKE-QUESTIONS.md` after all automations collected.

---

## Complexity Classifier

After collecting each automation, internally classify it:

**Low complexity:**
- Single trigger → single action → single destination
- No branching, no loops
- All services have native Make.com modules
- Estimated < 500 ops/month

**Medium complexity:**
- Multiple steps or branching logic
- One or more HTTP modules (no native integration)
- Estimated 500–5000 ops/month
- Data transformation or filtering required

**High complexity:**
- Multiple services or real-time webhooks
- Loops over arrays or batch processing
- Estimated > 5000 ops/month
- Payment, personal data, or health data involved
- External paid API calls at per-use pricing

---

## Priority Ranker

After all automations are collected, rank by:

1. **Highest business impact** — ask: "Which one would save you the most time
   or make you the most money?"
2. **Lowest complexity** — build easy wins first
3. **Dependencies** — if automation A feeds into B, build A first

Default order: easy/high-impact first → complex last.

Assign each automation a `priority` integer (1 = build first).
