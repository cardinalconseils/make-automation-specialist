---
name: ai-agent-designer
description: Designs AI agent architecture for Make.com scenarios. Determines model selection, tool inventory, memory strategy, looping pattern, and output contract. Called by scenario-orchestrator during System Design phase when ai_required is true, or directly by ai-agent-builder agent.
---

# Skill: ai-agent-designer

Designs AI agent architecture inside Make.com before any blueprint is written.
Called when an automation requires LLM reasoning, classification, generation, or decision-making.

## Sub-files

- `AGENT-DESIGN-INTAKE.md` — Interview protocol (5 questions), model selection matrix, tool inventory
- `AGENT-DESIGN-BLUEPRINT.md` — Blueprint output format, prompt engineering rules, output contract

## Deterministic Classification

This skill makes ONLY read-only MCP calls during design.
No `scenarios_create`, no `scenarios_update` — those happen in Sprint phase only.

Permitted: AskUserQuestion, `apps_recommend`, `app-modules_list`, `app-module_get`,
`app_documentation_get`, `data-stores_list`, Read / Write

## Precondition — Routing Verdict

Do not run this skill without a Routing Verdict from `skills/execution-model/SKILL.md`.

- `ai-agent` or `hybrid` → proceed. On `hybrid`, design the agent for **only** the
  indeterministic step named in the verdict, and give it a structured output contract so
  everything downstream is deterministic again.
- `scenario` → **stop.** Tell the user the automation is deterministic, cite the
  verdict's Reason line, and hand back to `plan-builder`. If they have information that
  changes the picture, re-run `execution-model` with it — never override the verdict
  silently.

For current Make AI Agent semantics — tool calling, memory, iteration limits — load
`skills/help-docs/SKILL.md` rather than answering from memory; this surface changes often.

## When to Call This Skill

The keyword list below is a **detection hint for the interview**, not the decision.
The decision is the Routing Verdict above.

Call this skill whenever an automation contains any of:
- "AI", "LLM", "language model", "ChatGPT", "Claude", "Gemini"
- "summarize", "classify", "generate", "decide", "extract", "respond intelligently"
- "AI agent", "chatbot", "autonomous", "tool use"
- "analyze this email and decide", "write a reply", "determine whether..."

If detected during kickstart-intake: mark `ai_required: true` in the automation object.
During Phase 2, the orchestrator calls this skill before plan-builder.

## Integration with Other Skills

After this skill completes:
1. Call `ai-docs-researcher` to look up exact Make.com module specs for the chosen model
2. Call `agent-pattern-library` to load the full pattern blueprint
3. Hand AI Agent Blueprint to `plan-builder` as additional context
4. The plan-builder incorporates the AI steps into the full AutomationPlan
