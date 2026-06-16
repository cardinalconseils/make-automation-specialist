---
name: brainstorm-sharp
description: "Diverge-then-converge for Make.com automation planning. Fires when the user has a business problem but no clear automation direction. Takes messy impulses like 'I'm wasting time on X' or 'I need to be more efficient' and produces ONE pointed direction sentence — the input that discovery-to-blueprint or kickstart-intake needs. Always routes to the next skill in the factory chain. Never produces standalone output."
version: "1.0.0"
---

# Brainstorm Sharp — Make.com Edition

## Purpose

The user knows they want to automate something but doesn't know what, exactly.
This skill converts "I keep manually entering leads from Typeform into our CRM"
into "Automatically sync new Typeform submissions into HubSpot as contacts, tagged
by form source." That one sentence is what `discovery-to-blueprint` or
`kickstart-intake` can work with.

**Never standalone.** Output is ONE direction sentence, then hand off.

## Hard Rules

1. Never present directions before capturing the business pain. Capture first.
2. Never stack questions. One at a time. ADHD-friendly.
3. Never more than 5 directions. More = paralysis.
4. Never generate scenario blueprints, module lists, or tech specs here.
5. Always route to the next step — never end here.

## Phase 1 — Capture the Pain

Ask exactly this (one question):

> "Tell me what you're doing manually that shouldn't be manual. One breath."

Wait. Take what comes. Do not ask a follow-up yet.

## Phase 2 — Diverge: Three Automation Lenses

Choose the 3 most relevant lenses based on what the user said:

**REPLACE (different user type):**
"What if this automation served a completely different role in your business than the obvious one?"

**COMBINE (merge two pain points):**
"What if you automated [thing they said] AND [adjacent manual step that emerged]?"

**ELIMINATE (strip to minimum):**
"If you automated only the single most painful moment — what's left? What's the one step that must be automatic?"

**REPURPOSE (new context):**
"The same automation logic, but applied to a completely different workflow — where else does this pattern exist in your business?"

**AMPLIFY (10× scale):**
"If this ran 10× more often or processed 10× more records, which part becomes the bottleneck? What would the automation need to handle?"

For each lens: short question, wait, reflect one line, move to next.
After all three: synthesize in 2–3 sentences. Do not present as directions yet.

## Phase 3 — Converge: Pick a Direction

Present 3–5 directions derived from the lenses. Each is ONE sentence:
`[automatically] [what happens] [for who/when] [so that outcome]`

Example: "Automatically create a HubSpot contact and assign to the right sales rep
whenever a Typeform lead submission comes in with a budget over $10K."

Ask:
> "Which one is it? Or tell me how to combine two."

If user picks one → Phase 4.
If user wants to combine → synthesize into ONE sentence, confirm → Phase 4.
If none fit → one more round: "What's closest? What's wrong with it?"

Do not loop more than twice. If stuck:
> "Pick the one that would embarrass you least to abandon. We can always course-correct
> during the blueprint."

## Phase 4 — Lock and Hand Off

State the direction:

> "Direction locked: [one sentence]"

Then assess complexity:
- **Simple** (single trigger → action → destination, native Make.com apps): hand off directly to kickstart-intake
- **Complex** (multi-step workflow, unclear data shapes, multiple integrations): offer discovery-to-blueprint first

For simple:
> "Simple automation — heading into the intake to spec this out."
> [Begin kickstart-intake with direction as seed]

For complex:
> "This has a few moving parts. Let's map the full flow before jumping to Make.com.
> Starting discovery — I'll ask one question at a time."
> [Begin discovery-to-blueprint Phase 1 with direction as seed]

## Deterministic Routing

This skill fires automatically in two cases:

1. **scenario-orchestrator Gate 0**: no automation direction detected at session start
2. **kickstart-intake**: user says "I don't know what to automate" or describes vague business pain

In both cases: output is a direction sentence → immediate hand-off to the appropriate next skill.
Never standalone output.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user described something — that's enough direction" | Test: does it have a trigger, action, and destination? If not, run this skill. |
| "I'll skip the lenses and go straight to directions" | Lenses are what generates non-obvious directions. Skip them and you get the obvious answer the user already had. |
| "The user is too vague to converge" | Force a pick: "Which one embarrasses you least to abandon?" It works. |
