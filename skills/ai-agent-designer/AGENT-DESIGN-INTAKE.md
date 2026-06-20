# AI Agent Designer: Interview Protocol

Ask these questions conversationally — never all at once.

## Question 1 — What should the AI do?

```
What decision or task do you want the AI to handle?
Examples:
• "Read an incoming email and decide whether it's a hot lead or not"
• "Summarize a long document into 3 bullet points"
• "Write a personalized reply based on the customer's question"
• "Classify a support ticket and route it to the right team"
• "Extract specific data from an unstructured text"
```

Classify the **agent task type**:

| Answer pattern | Task type | Pattern to use |
|---------------|-----------|---------------|
| decide / classify / route | Classifier | Router pattern |
| generate / write / draft | Generator | Single-shot pattern |
| summarize / condense | Summarizer | Chunk-and-summarize pattern |
| extract / parse | Extractor | Single-shot pattern |
| research / search + answer | RAG | RAG pattern |
| do multiple steps autonomously | ReAct agent | ReAct loop pattern |

## Question 2 — Which AI model?

If user has no preference, apply the model selection matrix:

| Task type | Recommended model | Est. cost/1M tokens |
|-----------|------------------|---------------------|
| Classifier (yes/no, category) | Claude Haiku 3 | ~$0.25 in / $1.25 out |
| Extractor (structured JSON) | Claude Sonnet 4 | ~$3 in / $15 out |
| Generator (email, copy) | Claude Sonnet 4 | ~$3 in / $15 out |
| Summarizer | Claude Haiku 3 | ~$0.25 in / $1.25 out |
| RAG (search + answer) | Claude Sonnet 4 | ~$3 in / $15 out |
| ReAct agent (multi-step) | Claude Sonnet 4 | ~$3 in / $15 out |
| Complex reasoning / analysis | Claude Opus 4 | ~$15 in / $75 out |

Always translate costs into plain language. Surface Make.com module options:
1. Make.com Anthropic module (native) → best for Claude models
2. Make.com OpenAI module (native) → best for GPT models
3. Make.com Google AI module (native) → best for Gemini models
4. HTTP module → last resort for other providers

## Question 3 — What tools does the agent need?

Collect **tool inventory** — each tool becomes a Make.com module, sub-scenario webhook, or HTTP request.

```json
{
  "tools": [
    {"name": "CRM lookup", "make_module": "HubSpot > Search Records", "trigger": "AI decides to look up customer"},
    {"name": "Send email", "make_module": "Gmail > Send Email", "trigger": "AI generates a reply"}
  ]
}
```

## Question 4 — Does the AI need memory?

Map to Make.com memory strategy:

| Memory type | Make.com implementation | Complexity |
|-------------|------------------------|------------|
| No memory | No data store needed | Low |
| Session memory | Make.com Variable module | Low |
| Persistent memory | Make.com Data Store | Medium |
| Knowledge base (RAG) | Supabase vector + pgvector | High |
| Conversation history | Data Store with thread ID | Medium |

## Question 5 — Single-shot or loop?

- **Single decision:** AI reads input once, produces output, done. → linear scenario
- **Loop (agent):** AI decides what to do, does it, checks result, decides again. → ReAct loop pattern

The loop is more powerful but uses more Make.com operations.
