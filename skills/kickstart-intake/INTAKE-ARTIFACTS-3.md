# Intake: Artifacts 5–6 and Summary

Part of `kickstart-intake`. See `INTAKE-ARTIFACTS.md` for execution order.

---

## Artifact 5 — stack.md

```markdown
# Required Stack
**Generated:** {date}

## Make.com Apps Required
| App | Purpose | Connection Name |
|-----|---------|----------------|
| {app} | {what it does in this project} | {suggested name} |

## API Keys / Credentials Needed
| Service | Credential Type | Where to Get It |
|---------|----------------|----------------|
| {service} | API Key / OAuth | {URL or instructions} |

## MCPs / External Tools
{List any MCP servers or external tools required beyond Make.com}
```

---

## Artifact 6 — ai-agents.md (conditional)

Only generate this file when one or more automations include AI/LLM steps.

```markdown
# AI Agent Inventory
**Generated:** {date}

## Agents in This Project

### {agent name}
**Automation:** {auto-id} — {title}
**Pattern:** {Router / Extractor / Summarizer / Classifier / Generator}
**Model:** {model id — verify via ai-docs-researcher before building}
**Input:** {what data enters the agent}
**Output:** {what it produces}
**Prompt location:** `.make/prompts/{slug}.md`
**Token estimate:** ~{n} input / ~{n} output per run
**Cost estimate:** ~${n}/month at {frequency}
```

---

## Artifact Generation Summary

After writing all artifacts, display to user:

```
Artifacts written to .make/:
  ✓ context/context.md       — project domain and goals
  ✓ prd.md                   — user stories and acceptance criteria
  ✓ context/erd.md           — integration map (Mermaid)
  ✓ context/system-design.md — architecture and trigger inventory
  ✓ context/stack.md         — required apps and credentials
  ✓ context/ai-agents.md     — AI agent inventory (if applicable)

Ready to hand off to the scenario-orchestrator for design and build.
```
