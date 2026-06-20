# AI Agent Builder — ai-agents.md Entry Format

Reference file for `agents/ai-agent-builder-intake.md`.

## Entry Format (append to `.make/context/ai-agents.md`)

```markdown
## {agent title} — {YYYY-MM-DD}

**Task type:** {classifier / generator / summarizer / extractor / RAG / ReAct}
**Pattern:** {pattern name}
**Model:** {model} via {provider module}

### Prompt

**System:** {system prompt}
**User template:** {user prompt with {{variables}}}

### Output Contract

Format: {JSON schema / plain text}
Fields: {list}

### Tools

| Tool | Make.com Module | When Used |
|------|----------------|-----------|
| {name} | {module} | {trigger condition} |

### Memory

Strategy: {none / variable / data-store / vector}
Implementation: {details}

### Make.com Blueprint

Pattern: {pattern reference}
Modules: {ordered list}

### Cost Estimate

Operations per run: ~{n}
Frequency: {n} times/month
Total operations/month: ~{n}
AI token cost/month: ~${n}
```

Also update `.make/prd.md` — append AI agent user story if PRD exists.

After build: mark entry as `status: built, scenario_id: {id}`.
