---
name: council-of-5
description: "Five adversarial voices that challenge an automation blueprint before significant resources are committed. Reads the discovery-to-blueprint output (process map + pre-mortem), each voice gives one honest paragraph, top concerns are extracted, user responds to the 2-3 highest-priority ones, then the council renders a verdict: Go / Go with condition / Pause / Pivot. Always triggered by discovery-to-blueprint Gate 2 when high-stakes signals present. Also available for standalone review of any high-commitment Make.com project. Never silent — always ends with a hand-off line."
version: "1.0.0"
---

# Council of Five — Make.com Edition

## Purpose

By the time the automation blueprint is written, the user is invested in the idea.
Five adversarial lenses — applied after the blueprint exists — surface what the
pre-mortem missed because the user's own framing shaped it.

The council does not replace the pre-mortem. It reads it, then challenges it.

## Hard Rules

1. **Read the blueprint first.** Do not start without the discovery-to-blueprint output.
   If it doesn't exist: "Run discovery-to-blueprint first — the council needs a blueprint."
2. **Each voice speaks once — one honest paragraph.** No softening, no balance.
3. **Never present all 5 concerns as equal.** Rank them. Extract top 2-3.
4. **User responds only to top 2-3.** Do not make them respond to all five.
5. **One verdict.** Go / Go with condition / Pause / Pivot. Not "it depends."
6. **Always end with the hand-off line.** Council → kickstart-intake or factory.

## The Five Voices

### 1. The Builder
*Function: Make.com feasibility + technical constraint reality-check*

Reads the tech fit table and process map. Asks: "Is this actually buildable natively
in Make.com? What is the single hardest module — the one where 'HTTP custom request' is
the fallback — and has the user accounted for the extra design time?" Flags any step
marked TBD or HTTP that is load-bearing. Does not suggest solutions — only names the gap.

### 2. The Skeptic
*Function: failure mode detection + glossed-over assumptions*

Reads the pre-mortem. Asks: "What is the most likely real failure mode — not the one
the user named, but the one beneath it? Which Elephant is being ignored?" Often finds
the assumption that the upstream data format is stable, or that the webhook never drops.

### 3. The User
*Function: maintenance reality-check*

Reads the blueprint's trigger and outcome. Asks: "Who maintains this scenario when it
breaks at 2am and the builder is unavailable? Does that person have the Make.com
access, the app credentials, and the knowledge to fix it? What is the real support path?"
If the answer is "the user figures it out," names it as a risk.

### 4. The Operator
*Function: post-activation sustainability*

Reads the process map and tech fit. Asks: "What happens at 3× the expected volume?
At what operation count does this become a cost problem? Who owns the operations budget?
What is the monthly cost model at scale, and who is accountable for it?" Flags anything
that is free to design but expensive to run.

### 5. The Contrarian
*Function: opportunity cost + platform fitness*

Reads the entire blueprint. Makes the case for NOT building this in Make.com. Asks:
"Is Make.com actually the right platform for this? Could a simpler Zapier zap, an n8n
flow, a direct API integration, or even a spreadsheet + scheduled script do this in 20%
of the time? Is the user choosing Make.com out of familiarity rather than fit?"

## Process

### Step 1 — Read

Silently read the full discovery-to-blueprint output:
- Automation brief, process map, tech fit table
- Pre-mortem output (tigers, elephants, go/no-go checklist)

### Step 2 — Each Voice Speaks

Present all five in sequence. Each gets one paragraph:

```
**The Builder:** [one paragraph]

**The Skeptic:** [one paragraph]

**The User:** [one paragraph]

**The Operator:** [one paragraph]

**The Contrarian:** [one paragraph]
```

### Step 3 — Extract Top Concerns

After presenting all five, extract:
- One top concern per voice (one sentence each)
- Rank by severity: which 2-3 are most likely to kill the project or burn out the user?

```
**Top concerns ranked:**
1. [Highest severity — voice name] — [one sentence]
2. [Second — voice name] — [one sentence]
3. [Third — voice name] — [one sentence]
```

### Step 4 — User Responds

Ask:
> "Respond to concerns 1 and 2. Just the ones that land."

Wait. Do not ask follow-up questions — let the response shape the verdict.

### Step 5 — Verdict

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

### Step 6 — Hand Off

Always close with the hand-off line:

- **Go:** "Heading into kickstart-intake. Your automation is ready to spec."
- **Go with condition:** "Resolve the condition, then return to kickstart-intake."
- **Pause:** "Validate [X], then re-run discovery-to-blueprint with the new information."
- **Pivot:** "Run brainstorm-sharp with this new direction, then re-discover."

## Deterministic Gate

This skill is automatically offered (never silently skipped) after `discovery-to-blueprint`
Phase 3 when the blueprint contains any of these signals:

- Operations cost: >$1K/month, "significant budget", "ROI required", "client billing"
- Commitment: "client contract", "SLA", "production system", "replaces live process"
- Scale: "10,000+ records", "real users", "live environment"
- Business: "revenue-generating", "compliance-required", "mission-critical"

When triggered: `discovery-to-blueprint` asks:
> "This looks high-stakes. Before we start building, should 5 critical voices review
> the plan? [Yes / Skip — proceed to build]"

User may say Skip. The offer cannot be silently omitted.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The pre-mortem already covered this" | The pre-mortem catches what the user could imagine. The council catches what the user's framing prevented them from imagining. |
| "The user is eager to build, skip the review" | The user can skip it by selecting Skip. You cannot skip it on their behalf. |
| "It's a simple automation, no council needed" | If it's truly simple, the council takes 5 minutes and confirms it. If it's not as simple as it looks, the council saves a sprint. |
| "The Contrarian is too negative" | The Contrarian surfaces the opportunity cost. A quick n8n flow or Zapier zap that does 80% of the value is a legitimate outcome — not a failure. |
