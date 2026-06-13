---
name: agent
description: Build an AI-powered agent inside Make.com. Guides model selection, tool inventory, memory strategy, and pattern choice — then designs and builds the scenario with full approval gates.
triggers:
  - /agent
  - /ai-agent
  - /ai
agent: ai-agent-builder
---

# /agent — Build an AI Agent in Make.com

Activates the **AI Agent Builder** for a guided design-and-build session.

## What this command does

Walks you through building an AI-powered automation in Make.com — step by step.
The AI agent can classify, generate, extract, summarize, or autonomously complete tasks.

## Usage

```
/agent
```
Start a fresh AI agent design session.

```
/agent summarize incoming emails and route them
```
Pass an initial description to skip the opening question.

```
/agent --audit
```
Review and improve an existing AI scenario in your workspace.

## What to expect

1. **Discovery** — I'll ask what the AI should do, which model to use, what tools it needs, and whether it needs memory.
2. **Research** — I look up the exact Make.com module specs for your chosen AI provider. No guessing.
3. **Design** — I produce a full blueprint with a Mermaid diagram, prompt template, cost estimate, and risk level.
4. **Your approval** — I show you the plan. Type "build" when ready.
5. **Build** — I build the scenario step by step, narrating each action.

## AI Agent Patterns Available

| Pattern | Use case | Example |
|---------|----------|---------|
| Classify-and-Route | Triage and routing | "Sort incoming leads by temperature" |
| Single-Shot Generator | Content generation | "Write a follow-up email for each new lead" |
| Chunk-and-Summarize | Long document processing | "Summarize meeting transcripts daily" |
| Structured Extractor | Data extraction | "Pull invoice fields from email attachments" |
| RAG | Knowledge base Q&A | "Answer customer questions from our FAQ" |
| ReAct Loop | Autonomous multi-step | "Research a company and prepare a brief" |
| Batch Processor | Bulk processing | "Classify all support tickets from last week" |

## Supported AI Providers

The builder looks up current specs from Make.com for all supported providers.
Common options include Anthropic (Claude), OpenAI (GPT), Google (Gemini), Mistral, and others.

## Related commands

- `/plan` — Generate a plan without building (useful for review before committing)
- `/audit` — Audit an existing AI scenario for issues
- `/diagram` — Generate a Mermaid diagram of an existing scenario
- `/factory` — Build a full portfolio of automations (includes AI agent support)
