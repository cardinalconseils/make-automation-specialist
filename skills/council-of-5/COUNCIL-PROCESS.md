# Council Process — Five-Advisor Steps and Verdict

Companion to `SKILL.md`. Defines the six-step process from reading the blueprint
to hand-off.

---

## Step 1 — Read

Silently read the full discovery-to-blueprint output:
- Automation brief, process map, tech fit table
- Pre-mortem output (tigers, elephants, go/no-go checklist)

---

## Step 2 — Each Voice Speaks

Present all five in sequence. Each gets one paragraph:

```
**The Builder:** [one paragraph]

**The Skeptic:** [one paragraph]

**The User:** [one paragraph]

**The Operator:** [one paragraph]

**The Contrarian:** [one paragraph]
```

---

## Step 3 — Extract Top Concerns

After presenting all five, extract:
- One top concern per voice (one sentence each)
- Rank by severity: which 2-3 are most likely to kill the project or burn out the user?

```
**Top concerns ranked:**
1. [Highest severity — voice name] — [one sentence]
2. [Second — voice name] — [one sentence]
3. [Third — voice name] — [one sentence]
```

---

## Step 4 — User Responds

Ask:
> "Respond to concerns 1 and 2. Just the ones that land."

Wait. Do not ask follow-up questions — let the response shape the verdict.

---

## Step 5 — Verdict

After response, render the verdict:

| Verdict | When | What it means |
|---|---|---|
| **Go** | Top concerns addressed or overruled with reasoning | Proceed to kickstart-intake |
| **Go with condition** | Concerns partially addressed; specific condition must be met | Proceed only after [explicit condition] |
| **Pause** | Top concern is unresolved and changes the build | Validate [specific thing] before committing |
| **Pivot** | The Contrarian's case is stronger than the blueprint's | Name the better direction |

Format:

```
**Council verdict: [Go / Go with condition / Pause / Pivot]**

[One sentence rationale.]

[If Go with condition: "Condition: [explicit thing that must be true before sprint starts]"]
[If Pause: "Validate first: [specific thing], then return."]
[If Pivot: "Better direction: [one sentence]"]
```

---

## Step 6 — Hand Off

Always close with the hand-off line:

- **Go:** "Heading into kickstart-intake. Your automation is ready to spec."
- **Go with condition:** "Resolve the condition, then return to kickstart-intake."
- **Pause:** "Validate [X], then re-run discovery-to-blueprint with the new information."
- **Pivot:** "Run brainstorm-sharp with this new direction, then re-discover."
