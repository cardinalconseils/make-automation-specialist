---
name: ai-agent-designer
description: Designs AI agent architecture for Make.com scenarios. Determines model selection, tool inventory, memory strategy, looping pattern, and output contract. Called by scenario-orchestrator during System Design phase when ai_required is true, or directly by ai-agent-builder agent.
---

# Skill: ai-agent-designer

Designs AI agent architecture inside Make.com before any blueprint is written.
Called when an automation requires LLM reasoning, classification, generation, or decision-making.

## Deterministic Classification

This skill makes ONLY read-only MCP calls during design.
No `scenarios_create`, no `scenarios_update` — those happen in Sprint phase only.

Permitted:
- AskUserQuestion
- `mcp__claude_ai_Make__apps_recommend`
- `mcp__claude_ai_Make__app-modules_list`
- `mcp__claude_ai_Make__app-module_get`
- `mcp__claude_ai_Make__app_documentation_get`
- `mcp__claude_ai_Make__data-stores_list`
- Read / Write

---

## When to Call This Skill

Call this skill whenever an automation contains any of:
- "AI", "LLM", "language model", "ChatGPT", "Claude", "Gemini"
- "summarize", "classify", "generate", "decide", "extract", "respond intelligently"
- "AI agent", "chatbot", "autonomous", "tool use"
- "analyze this email and decide", "write a reply", "determine whether..."

If detected during kickstart-intake: mark `ai_required: true` in the automation object.
During Phase 2, the orchestrator calls this skill before plan-builder.

---

## Interview Protocol

Ask these questions conversationally — never all at once.

### Question 1 — What should the AI do?

```
What decision or task do you want the AI to handle?

Examples:
• "Read an incoming email and decide whether it's a hot lead or not"
• "Summarize a long document into 3 bullet points"
• "Write a personalized reply based on the customer's question"
• "Classify a support ticket and route it to the right team"
• "Extract specific data from an unstructured text"
```

Based on the answer, classify the **agent task type**:

| Answer pattern | Task type | Pattern to use |
|---------------|-----------|---------------|
| decide / classify / route | Classifier | Router pattern |
| generate / write / draft | Generator | Single-shot pattern |
| summarize / condense | Summarizer | Chunk-and-summarize pattern |
| extract / parse | Extractor | Single-shot pattern |
| research / search + answer | RAG | RAG pattern |
| do multiple steps autonomously | ReAct agent | ReAct loop pattern |

---

### Question 2 — Which AI model?

```
Do you have a preference for which AI to use?

If you're not sure, I'll recommend one based on your use case.
```

If user has no preference, apply the model selection matrix:

| Task type | Recommended model | Why | Est. cost/1M tokens |
|-----------|------------------|-----|---------------------|
| Classifier (yes/no, category) | Claude Haiku 3 | Fast, cheap, accurate | ~$0.25 in / $1.25 out |
| Extractor (structured JSON) | Claude Sonnet 4 | Best at following schemas | ~$3 in / $15 out |
| Generator (email, copy) | Claude Sonnet 4 | Best writing quality | ~$3 in / $15 out |
| Summarizer | Claude Haiku 3 | Cost-efficient for bulk | ~$0.25 in / $1.25 out |
| RAG (search + answer) | Claude Sonnet 4 | Best at grounding | ~$3 in / $15 out |
| ReAct agent (multi-step) | Claude Sonnet 4 | Best reasoning + tool use | ~$3 in / $15 out |
| Complex reasoning / analysis | Claude Opus 4 | Highest capability | ~$15 in / $75 out |

Always translate costs into plain language:
```
Claude Haiku 3 is the most affordable option — processing 1,000 emails would cost roughly $0.01–0.05 in AI usage, plus Make.com operations.
```

Surface Make.com module options:
1. **Make.com Anthropic module** (native) → best for Claude models
2. **Make.com OpenAI module** (native) → best for GPT models
3. **Make.com Google AI module** (native) → best for Gemini models
4. **HTTP module** → for any other model provider (last resort)

---

### Question 3 — What tools does the agent need?

```
Does the AI need to take actions or look things up — or just process text it receives?

For example:
• Look up a customer in your CRM
• Search the web for current information
• Send an email or Slack message
• Read from a Google Sheet or database
• Or just: analyze the text I send it and give me a structured answer
```

Collect **tool inventory** — each tool becomes either:
- A Make.com module in the same scenario (in a router branch)
- A webhook call to a sub-scenario
- An HTTP request to an external API

Tool inventory template:
```json
{
  "tools": [
    {
      "name": "CRM lookup",
      "make_module": "HubSpot > Search Records",
      "trigger": "AI decides to look up customer"
    },
    {
      "name": "Send email",
      "make_module": "Gmail > Send Email",
      "trigger": "AI generates a reply"
    }
  ]
}
```

---

### Question 4 — Does the AI need memory?

```
Should the AI remember things from one conversation or run to the next?

• No memory needed — each run is independent (simplest option)
• Remember within one conversation — session memory only
• Remember across many conversations or runs — persistent memory
• Search through a large knowledge base — vector/semantic search
```

Map to Make.com memory strategy:

| Memory type | Make.com implementation | Complexity |
|-------------|------------------------|------------|
| No memory | No data store needed | Low |
| Session memory | Make.com Variable module | Low |
| Persistent memory | Make.com Data Store | Medium |
| Knowledge base (RAG) | Supabase vector + pgvector | High |
| Conversation history | Data Store with thread ID | Medium |

---

### Question 5 — Single-shot or loop?

```
Should the AI make a single decision and stop, or keep going until it finishes a task?

• Single decision: AI reads input once, produces output, done.
• Loop (agent): AI decides what to do, does it, checks the result, decides what to do next — repeating until the task is complete.

The loop is more powerful but uses more Make.com operations.
```

Map to pattern:
- **Single-shot** → linear scenario (no routing loop needed)
- **ReAct loop** → Make.com scenario with Iterator + Router that can loop back

---

## AI Agent Blueprint Output

After the interview, produce an **AI Agent Blueprint**:

```
AI AGENT BLUEPRINT: {title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Task type:      {Classifier / Generator / Summarizer / RAG / ReAct}
Pattern:        {pattern name from agent-pattern-library}
Model:          {model name}
Provider:       {Anthropic / OpenAI / Google}
Make.com module: {exact module name}

TOOLS AVAILABLE TO AGENT
  {tool name}    → {Make.com module}
  ...

MEMORY STRATEGY
  {memory type} → {implementation}

INPUT
  {what data enters the AI — field names and sources}

PROMPT TEMPLATE
  System: {what role the AI plays}
  User:   {what the AI receives each run}

OUTPUT CONTRACT
  Format:  {JSON schema / plain text / boolean}
  Fields:  {list expected fields if JSON}

MAKE.COM OPERATIONS ESTIMATE
  Per run:   ~{n} operations
  Per month: ~{n} operations (at {frequency})
  AI cost:   ~${n}/month (at estimated token usage)

PATTERN DIAGRAM
  [Mermaid flowchart from agent-pattern-library]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Save to: `.make/context/ai-agents.md` (append if file exists)

---

## Prompt Engineering Rules

When writing the system prompt for the agent:

1. **Role first** — "You are a {role} that {task}."
2. **Output contract second** — "Always respond in valid JSON with these fields: {...}"
3. **Constraints third** — "Never include explanation text outside the JSON object."
4. **Examples last (optional)** — include 1-2 examples for structured output tasks

Never use vague prompts like "analyze this and help". Always specify the exact output format.

For structured outputs (JSON), include a schema in the prompt:
```
Respond ONLY with valid JSON matching this schema:
{
  "classification": "hot_lead" | "cold_lead" | "not_a_lead",
  "confidence": 0.0–1.0,
  "reason": "one sentence"
}
```

---

## Integration with Other Skills

After this skill completes:
1. Call `ai-docs-researcher` to look up exact Make.com module specs for the chosen model
2. Call `agent-pattern-library` to load the full pattern blueprint
3. Hand AI Agent Blueprint to `plan-builder` as additional context
4. The plan-builder incorporates the AI steps into the full AutomationPlan

---

## Output Contract to Orchestrator

```json
{
  "ai_agent_blueprint": {
    "task_type": "classifier|generator|summarizer|extractor|rag|react",
    "pattern": "router|single-shot|rag|react-loop|chunk-and-summarize",
    "model": "claude-haiku-3|claude-sonnet-4|claude-opus-4|gpt-4o|gpt-4o-mini|gemini-pro",
    "provider": "anthropic|openai|google",
    "make_module": "exact module name",
    "tools": [...],
    "memory_strategy": "none|variable|data-store|vector",
    "prompt_template": {
      "system": "...",
      "user": "..."
    },
    "output_format": "json|text|boolean",
    "output_schema": {...},
    "ops_per_run": 0,
    "ai_cost_per_month_usd": 0
  }
}
```
