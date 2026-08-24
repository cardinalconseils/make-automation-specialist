---
name: execution-model
description: Decides whether an automation should be built as a deterministic Make.com scenario, as an AI Agent, or as a hybrid (scenario shell with an AI Agent at the one indeterministic step). Produces a Routing Verdict recorded in the plan. Called before any blueprint is designed.
allowed-tools: Read, Write, AskUserQuestion
---

# Skill: execution-model

Every automation gets one routing decision before any blueprint exists. Making it
explicitly — and writing down why — is what stops the two expensive mistakes:
an LLM call on a path that a filter could have decided, or a rigid router on a path
that needs judgement.

## The test

Apply per automation, not per project:

> **Can every branch be enumerated at design time as a filter or router condition over
> known fields?**
>
> - **Yes → `scenario`.** Deterministic. Reproducible, auditable, 1 operation per module,
>   no model cost, no drift.
> - **No → the indeterministic part needs an AI Agent.** A branch requires interpreting
>   unstructured input, or the sequence of tools to call is not knowable ahead of time.

Then ask the second question, which decides between `ai-agent` and `hybrid`:

> **How much of the flow is actually indeterministic?**
>
> - One step (classify, extract, summarise, draft) → **`hybrid`**
> - The whole control flow — the agent decides which tools to call, in what order, and
>   when it is done → **`ai-agent`**

## `hybrid` is the expected default

Most real automations are a deterministic pipeline with exactly one judgement call in
the middle: a deterministic trigger, an AI Agent module at the one step that needs
interpretation, then deterministic routing on its **structured output**.

Wrapping an entire deterministic pipeline in an agent is the common failure. It costs a
model call per operation, is non-reproducible run to run, and turns a filter bug — which
you can read — into a prompt bug, which you cannot. When in doubt, shrink the agent's
job until only the genuinely indeterministic step remains.

Corollary: an AI Agent step should **return structured output** so everything downstream
of it is deterministic again.

## Signals

| Points to `scenario` | Points to an agent |
|---|---|
| Trigger fields are structured (webhook payload, row, record) | Input is free text, email body, transcript, image, PDF |
| Branches map to known enum values or thresholds | "Decide which…", "figure out whether…", "route it appropriately" |
| Same input must always produce the same output | Output is a judgement, a summary, or drafted prose |
| Auditability or compliance matters on this path | The number of steps varies per input |
| High volume — per-run cost dominates | Low volume, high per-item value |

Ambiguity is not a tie-break in favour of the agent. If you cannot name the specific
step that needs judgement, the verdict is `scenario`.

## Output — the Routing Verdict

Emit this block verbatim into the plan, and into `.make/context/ai-agents.md` when the
verdict is not `scenario`:

```
Routing Verdict: scenario | ai-agent | hybrid
Indeterministic step: {the one step, or "none"}
Reason: {one line — what could not be enumerated at design time}
```

Set `ai_required` from the verdict: `true` for `ai-agent` and `hybrid`, `false` for
`scenario`. This replaces keyword matching — a plan that merely mentions "summary" in
prose is not an AI requirement.

## Downstream contract

- `plan-builder` — carries `routing_verdict` on the AutomationPlan.
- `ai-agent-designer` / `ai-agent-builder` — run only when the verdict is `ai-agent` or
  `hybrid`. On a `scenario` verdict, refuse and cite the Reason line; if the user wants
  an agent anyway, re-run this skill with their new information rather than overriding
  the verdict silently.
- `blueprint-review` — on `hybrid`, confirm the AI Agent module returns structured
  output and that the downstream routing reads that structure rather than raw text.

## Worked examples

| Ask | Verdict | Why |
|---|---|---|
| New Stripe charge → append a row in Sheets | `scenario` | Every field is known and mapped; no branch needs judgement |
| Inbound email → route to the right team | `hybrid` | Trigger and delivery are deterministic; classifying the body is not |
| Watch a shared inbox, research each request, use whichever tools it needs, reply | `ai-agent` | Neither the tool sequence nor the step count is knowable at design time |
| Form submission → if amount > 5000 route to approver, else auto-approve | `scenario` | A threshold is a filter, not a judgement |
