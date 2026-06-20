---
name: agent-pattern-library
description: Library of proven Make.com AI agent patterns. Returns the matching pattern blueprint — Mermaid diagram, module sequence, and wiring notes — based on the task type identified by ai-agent-designer. Called during System Design phase before plan-builder.
---

# Skill: agent-pattern-library

Provides battle-tested Make.com AI agent patterns.

Do not design from scratch when a proven pattern exists.
Match the task type to a pattern, load it, and adapt the specifics.

## Sub-files

- `PATTERNS-BASIC.md` — Patterns 1–4 (Classify-and-Route, Generator, Chunk-and-Summarize, Structured Extractor)
- `PATTERNS-ADVANCED.md` — Patterns 5–7 (RAG, ReAct Loop, Batch Processor) + selection logic
- `PATTERNS-OUTPUT.md` — Output contract returned to calling skill/agent

## Pattern Index

| Task type | Pattern | Complexity | Ops/run estimate |
|-----------|---------|------------|-----------------|
| Classifier / Router | Pattern 1: Classify-and-Route | Low | 3–5 |
| Generator | Pattern 2: Single-Shot Generator | Low | 2–3 |
| Summarizer | Pattern 3: Chunk-and-Summarize | Medium | 4–8 |
| Extractor | Pattern 4: Structured Extractor | Low | 2–3 |
| RAG (search + answer) | Pattern 5: Retrieval-Augmented Generator | Medium | 5–10 |
| ReAct agent | Pattern 6: ReAct Loop | High | 10–50+ |
| Batch processor | Pattern 7: Batch AI Processor | Medium | 3 × batch size |

## Pattern Selection Logic

```
IF task = "decide which category" OR "route to team" OR "score"
  → Pattern 1: Classify-and-Route

ELSE IF task = "write" OR "generate" OR "draft" OR "suggest"
  → Pattern 2: Single-Shot Generator

ELSE IF task = "summarize long document" OR "condense"
  → Pattern 3: Chunk-and-Summarize

ELSE IF task = "extract fields" OR "parse" OR "pull data from"
  → Pattern 4: Structured Extractor

ELSE IF task = "answer questions from" OR "FAQ" OR "knowledge base"
  → Pattern 5: RAG

ELSE IF task = "autonomously complete" OR "research and do" OR "multi-step"
  → Pattern 6: ReAct Loop

ELSE IF task = "process a list" OR "batch" OR "run on each row"
  → Pattern 7: Batch Processor
```
