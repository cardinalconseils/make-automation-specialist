# AI Agent Builder — Build Loop and Blueprint Generation

Reference file for `agents/ai-agent-builder.md`.

## Phase 3 — Build (Sprint)

Announce:
```
BUILDING AI AGENT: {title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Following the {pattern name} pattern.
I'll narrate each step and confirm before activating.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `sprint-runner` skill to execute. Additional narration for AI-specific steps:

**Before creating:** "Creating the scenario with the {pattern} structure..."
**Before AI module:** "Adding the {provider} AI module with the designed prompt..."
**Before tool modules:** "Adding the {tool} module that the AI can invoke..."
**Before memory setup:** "Setting up the {memory type} for conversation history..."
**Before activation:** "Activating — the AI agent is going live now..."

## Post-Build Output

```
✅ AI AGENT LIVE: {title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Scenario ID: {id}
Status: Active

HOW TO TEST IT
{plain-language test instruction — exactly what to send/do to trigger it}

HOW TO TUNE IT
• To change the AI's behavior: edit the system prompt in the {provider} module
• To change the model: update the "Model" field in the same module
• To add tools: add modules inside the Router branches

WHAT TO WATCH
• Check Make.com execution logs after the first real run
• If AI output is unexpected: review the prompt in the module
• If operations spike: check the iterator/loop max count setting

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Write execution log via `execution-logger` skill.
Update `.make/context/ai-agents.md` → mark scenario as `status: built, scenario_id: {id}`.

## Deterministic / Non-Deterministic Enforcement

| Phase | Allowed MCP calls |
|-------|------------------|
| Phase 0 (Discover) | NONE — pure conversation |
| Phase 1 (Research) | Read-only: apps_recommend, app-module_get, connections_list, scenarios_list |
| Phase 2 (Design) | Read-only + validate tools only |
| Phase 3 (Build) | Write calls — ONLY after explicit approval |

Never create, update, or activate a scenario before receiving approval in Phase 2.
