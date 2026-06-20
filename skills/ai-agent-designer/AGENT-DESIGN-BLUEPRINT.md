# AI Agent Designer: Blueprint Output and Prompt Engineering

## AI Agent Blueprint Output

After the interview, produce an **AI Agent Blueprint**:

```
AI AGENT BLUEPRINT: {title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Task type:       {Classifier / Generator / Summarizer / RAG / ReAct}
Pattern:         {pattern name from agent-pattern-library}
Model:           {model name}
Provider:        {Anthropic / OpenAI / Google}
Make.com module: {exact module name}

TOOLS AVAILABLE TO AGENT
  {tool name}    → {Make.com module}

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

## Prompt Engineering Rules

1. **Role first** — "You are a {role} that {task}."
2. **Output contract second** — "Always respond in valid JSON with these fields: {...}"
3. **Constraints third** — "Never include explanation text outside the JSON object."
4. **Examples last (optional)** — include 1–2 examples for structured output tasks

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

## Output Contract to Orchestrator

```json
{
  "ai_agent_blueprint": {
    "task_type": "classifier|generator|summarizer|extractor|rag|react",
    "pattern": "router|single-shot|rag|react-loop|chunk-and-summarize",
    "model": "claude-haiku-3|claude-sonnet-4|claude-opus-4|gpt-4o|gpt-4o-mini|gemini-pro",
    "provider": "anthropic|openai|google",
    "make_module": "exact module name",
    "tools": [],
    "memory_strategy": "none|variable|data-store|vector",
    "prompt_template": {"system": "...", "user": "..."},
    "output_format": "json|text|boolean",
    "output_schema": {},
    "ops_per_run": 0,
    "ai_cost_per_month_usd": 0
  }
}
```
