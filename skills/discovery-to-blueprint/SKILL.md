---
name: discovery-to-blueprint
description: "Conversational automation discovery that runs BEFORE any scenario design. Walks through a business process one question at a time, builds a structured automation blueprint: process map, data shapes, tech fit, Gary Klein pre-mortem risk gate, and next-step handoff to kickstart-intake. Fire when user says: discover this, blueprint this, map this out, I don't know the steps yet, help me scope, before I build, or when brainstorm-sharp produces a complex direction with multiple moving parts."
version: "1.0.0"
---

# Discovery to Blueprint — Make.com Edition

## Purpose

The user locked a direction in brainstorm-sharp but doesn't know the steps, the
data shapes, or which Make.com apps to use. This skill asks one question at a time,
extracts the structure, and produces a pre-flight bundle that kickstart-intake can
consume directly — no translation required.

**Never standalone.** Every run ends with a hand-off to kickstart-intake.

Detailed interview steps and output bundle format: see `BLUEPRINT-DISCOVERY-STEPS.md`.

## Hard Rules

1. **One question at a time.** Never stack questions.
2. **Conversation first, artifacts last.** No blueprint until intake is done and confirmed.
3. **Reflect, don't interrogate.** Mirror one line after each answer, then ask the next.
4. **No fabrication.** Unknown steps, data shapes, or apps → logged as open questions.
5. **Klein framing for risk.** Pre-mortem uses past tense: "it failed" — never "it might fail".

## Deterministic Gates

### Gate 1 — Direction Check (before Phase 1)

If the user's input has no trigger, no action, no destination → MUST route to
`brainstorm-sharp` first.

Say: "Before we map this, let's find the direction. One question at a time."
Then run brainstorm-sharp. After direction locked, Phase 1 begins automatically.

### Gate 2 — Stakes Check (after Phase 3, before hand-off)

Scan the blueprint for high-stakes signals:
- Budget: ">$1K/month operations", "significant cost", "ROI required"
- Commitment: "client contract", "SLA", "production system", "replaces current process"
- Scale: "10,000+ records", "real users", "live environment"
- Business: "revenue-generating", "compliance-required", "mission-critical"

If signals present → MUST offer `council-of-5`:
"This looks high-stakes. Before we start building, should 5 critical voices review
the automation plan? [Yes / Skip — proceed to build]"

User can say Skip — the offer cannot be silently omitted.

## Composition

```
brainstorm-sharp → discovery-to-blueprint → [council-of-5] → kickstart-intake → factory
  (Gate 1: if no                             (Gate 2: if
  direction)                                 high-stakes)
```

This skill never produces standalone output — every run ends with a hand-off line.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user described the automation — I can skip intake" | Run the backward chain. Every complex automation has hidden steps that emerge only when walking backward. |
| "Pre-mortem is overkill for a simple scenario" | Klein's 15-minute gate has caught more blocking elephants than any design review. Run it. |
| "I'll use hypothetical framing — 'what might fail'" | Klein's mechanism requires past tense. "It has failed" activates pattern recall. Forward framing produces vague worry. |
| "The tech fit is obvious, I don't need to ask" | Unknown modules at this stage become sprint blockers. Surface them now. |
