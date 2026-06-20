---
name: ai-docs-researcher
description: Fetches exact Make.com AI module specifications before any AI agent blueprint is built. Extends docs-researcher specifically for LLM/AI modules (Anthropic, OpenAI, Google AI, Hugging Face, Make.com AI Agent). Returns precise field names, model enums, token limits, and operation costs.
---

# Skill: ai-docs-researcher

Specialized extension of `docs-researcher` for AI/LLM modules in Make.com.

Never guess AI module parameters. Model IDs, parameter names, and enum values change
frequently — a stale assumption breaks the blueprint silently.

---

## When to Call This Skill

Call this skill before designing any scenario that includes:
- An AI model call (Claude, GPT, Gemini, etc.)
- A Make.com AI Agent module
- A Hugging Face inference call
- Any vector embedding operation

Called by `ai-agent-designer` after blueprint draft. Called by `ai-agent-builder` agent before building.

---

## Lookup Sequence

See [AI-DOCS-LOOKUP.md](./AI-DOCS-LOOKUP.md) for the full 5-step lookup sequence:
steps, MCP calls, provider search terms, and the AI Module Spec Card output format.

---

## Model Reference and Fallbacks

See [AI-DOCS-REFERENCE.md](./AI-DOCS-REFERENCE.md) for:
- Current model reference table (August 2025 baseline)
- HTTP module fallback instructions (when no native module exists)
- Connection verification steps and missing connection format
- Output contract (JSON returned to calling skill/agent)

---

## Core Rule

Always call `app-module_get` to get the current model enum.
Never hardcode model IDs — they change and break blueprints silently.
