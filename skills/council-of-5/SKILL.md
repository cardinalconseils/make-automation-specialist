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

Detailed process steps and verdict format: see `COUNCIL-PROCESS.md`.

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
in Make.com? What is the single hardest module — the one where 'HTTP custom request'
is the fallback — and has the user accounted for the extra design time?" Flags any
step marked TBD or HTTP that is load-bearing. Does not suggest solutions — only
names the gap.

### 2. The Skeptic
*Function: failure mode detection + glossed-over assumptions*

Reads the pre-mortem. Asks: "What is the most likely real failure mode — not the one
the user named, but the one beneath it? Which Elephant is being ignored?" Often finds
the assumption that the upstream data format is stable, or that the webhook never drops.

### 3. The User
*Function: maintenance reality-check*

Reads the blueprint's trigger and outcome. Asks: "Who maintains this scenario when
it breaks at 2am and the builder is unavailable? Does that person have the Make.com
access, the app credentials, and the knowledge to fix it?" If the answer is "the
user figures it out," names it as a risk.

### 4. The Operator
*Function: post-activation sustainability*

Reads the process map and tech fit. Asks: "What happens at 3× the expected volume?
At what operation count does this become a cost problem? Who owns the operations
budget?" Flags anything that is free to design but expensive to run.

### 5. The Contrarian
*Function: opportunity cost + platform fitness*

Reads the entire blueprint. Makes the case for NOT building this in Make.com. Asks:
"Could a simpler Zapier zap, an n8n flow, a direct API integration, or even a
spreadsheet + scheduled script do this in 20% of the time?"

## Deterministic Gate

Automatically offered (never silently skipped) after `discovery-to-blueprint` Phase 3
when the blueprint contains any of these signals:

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
| "The Contrarian is too negative" | The Contrarian surfaces the opportunity cost. A legitimate outcome — not a failure. |
