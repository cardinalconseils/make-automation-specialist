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

## When to Call This Skill

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
