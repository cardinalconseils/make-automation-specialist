---
name: kickstart-intake
description: Automation portfolio discovery interview. Guides the user to articulate every automation they need before any design begins. Produces a prioritized portfolio list. Called by scenario-orchestrator during the Kickstart phase.
---

# Skill: kickstart-intake

Conducts a conversational interview to discover the full portfolio of automations
the user needs. Returns a prioritized, structured list of automation requirements.

This skill is called by the scenario-orchestrator at the start of a `/factory` run.
Never design or build during this skill — only discover.

## Deterministic Classification — This Skill Is Read-Only

This skill makes ZERO Make.com MCP calls. It is pure conversation and file writes.
All operations here are deterministic. No approval gates apply.

Permitted operations:
- AskUserQuestion (conversational intake)
- Read / Write (session file, output docs)
- Bash (read `.make/workspace.json` if already available)

BLOCKED operations (must never be called in this skill):
- Any `mcp__claude_ai_Make__*` tool call
- Any non-deterministic operation

If you find yourself about to call a Make.com MCP tool during kickstart-intake,
you are in the wrong skill. Stop and return to the orchestrator.

---

## Input Contract

Receives from orchestrator:
- `seed` (optional) — an initial automation idea if the user provided one with the command
- `existing_automations` — list from workspace map (to avoid duplicates)

---

## Discovery Interview Protocol

### Opening (if seed provided)
```
Great — let's start with "{seed}".

To design this properly, I need a few quick details:
- What triggers this? (A form submission, a new email, a schedule, a customer action?)
- What should happen as a result?
- Where does the output go?
```

### Opening (no seed)
```
Let's map out what you want to automate.
What's the first thing you wish happened automatically in your business?
Tell me in plain language — no technical details needed.
```

### Per-Automation Collection Loop

For each automation the user describes, collect:

| Field | Question | Required? |
|-------|----------|-----------|
| `trigger` | "What starts this off?" | Yes |
| `action` | "What should happen as a result?" | Yes |
| `destination` | "Where does the result go?" | Yes |
| `frequency` | "How often does this run?" | Yes |
| `error_pref` | "If something goes wrong — log quietly or alert you?" | No (default: log + alert) |
| `budget` | "Any monthly cost limit to stay within?" | No |
| `ai_required` | Detected automatically (see AI Detection below) | Auto |

### AI Agent Detection

After collecting `trigger` + `action` + `destination` for each automation,
scan the user's description for AI signals:

**AI signal phrases:**
- "AI", "ChatGPT", "Claude", "GPT", "Gemini", "language model", "LLM"
- "summarize", "classify", "generate text", "write a", "draft a"
- "decide", "analyze and", "intelligently", "smart", "automatically determine"
- "extract from", "parse", "understand the meaning", "respond to"
- "chatbot", "virtual assistant", "AI agent", "autonomous"

**If any signal is detected:**
1. Set `ai_required: true` on the automation object
2. Ask one clarifying question:
   ```
   It sounds like this automation needs AI to make a decision or generate content.
   Just to confirm — what should the AI specifically do?
   (e.g., "classify the email as hot or cold", "write a reply", "extract the invoice total")
   ```
3. Record the answer as `ai_task_description`
4. Do NOT design the AI agent here — that happens in Phase 2 via `ai-agent-designer`

**In the portfolio display**, mark AI automations:
```
[2] {title}                             [Medium complexity] [🤖 AI]
    When {trigger}
    → AI will: {ai_task_description}
    → Result goes to: {destination}
```

After collecting trigger + action + destination, reflect it back:
```
Got it — so when {trigger}, you want me to {action} and send it to {destination}.
{If frequency unclear}: About how often does this happen?
```

Confirm before moving on:
```
Adding this to your portfolio. Anything to change about that description?
```

### After Each Automation

Ask:
```
Is there anything else you'd like to automate, or shall we move on to designing these?
```

Keep looping until the user says they're done (phrases: "that's it", "that's all", "no more", "let's go", "ready", etc.).

### Complexity Classifier

After collecting each automation, internally classify it:

**Low complexity:**
- Single trigger → single action → single destination
- No branching, no loops
- All services have native Make.com modules
- Estimated < 500 ops/month

**Medium complexity:**
- Multiple steps or branching logic
- One or more HTTP modules (no native integration)
- Estimated 500–5000 ops/month
- Data transformation or filtering required

**High complexity:**
- Multiple services or real-time webhooks
- Loops over arrays or batch processing
- Estimated > 5000 ops/month
- Payment, personal data, or health data involved
- External paid API calls at per-use pricing

### Priority Ranker

After all automations are collected, rank by:
1. Highest business impact (ask: "Which one would save you the most time / make the most money?")
2. Lowest complexity (build easy wins first)
3. Dependencies (if A feeds into B, build A first)

Simple default order: easy/high-impact first → complex last.

---

---

## Project Artifact Generation

After the portfolio is confirmed, generate 5 project-level artifacts to `.make/context/`.
These are file writes only — no MCP calls. Deterministic classification preserved.

### Artifact 1 — context.md

Synthesize the interview answers into a project context document:

```markdown
# Automation Project Context

**Generated:** {date}
**Project:** {descriptive project name derived from automations}

## Domain
{What business area these automations serve — e.g., "Lead Generation & CRM Sync for B2B SaaS"}

## Users
{Who will benefit from these automations, and who will maintain them}

## Goals
{What the user is trying to achieve — in plain language, not automation terms}
{e.g., "Never manually enter a lead again. Know instantly when a deal closes."}

## Integrations Required
{List every service mentioned across all automations}
- {Service}: {how it's used}

## Constraints
{Budget limits, timing requirements, compliance concerns, data sensitivity}

## Automations in Scope ({n} total)
{Brief one-line description of each, in build order}
1. {title} — {trigger} → {action}
2. {title} — ...
```

Save to: `.make/context/context.md`

### Artifact 2 — prd.md

Full product requirements document for the automation project:

```markdown
# Automation Project PRD

**Version:** 1.0  
**Date:** {date}

## Overview
{2-paragraph plain-language description of what this automation system does and why it matters}

## Automations

### {auto-001}: {title}
**Priority:** {1-n}
**Complexity:** {Low/Medium/High}

**User Story:**
As a {role}, I want {trigger event} to automatically {action}, so that {business outcome}.

**Acceptance Criteria:**
- [ ] When {trigger condition}, {action} happens within {time expectation}
- [ ] If the automation fails, {error handling requirement}
- [ ] {Any data quality or compliance requirement}

**Inputs:** {data that enters the automation}
**Outputs:** {what it produces or sends}
**Frequency:** {how often it runs}
**Cost:** ~{n} ops/month

---
### {auto-002}: ...
```

Save to: `.make/prd.md` (project root — primary reference document)

### Artifact 3 — erd.md

Data flow diagram showing how data moves between systems:

```markdown
# Automation Data Flow

**Generated:** {date}

## Integration Map

\`\`\`mermaid
flowchart LR
  subgraph Sources
    S1["{trigger service 1}"]
    S2["{trigger service 2}"]
  end
  
  subgraph Make.com
    M1["{automation title 1}"]
    M2["{automation title 2}"]
  end
  
  subgraph Destinations
    D1["{destination service 1}"]
    D2["{destination service 2}"]
  end
  
  S1 -->|"{data type}"| M1
  S2 -->|"{data type}"| M2
  M1 -->|"{data type}"| D1
  M2 -->|"{data type}"| D2
  M1 -->|"{data type}"| D2
\`\`\`

## Data Objects

| Object | Source | Used By | Destination |
|--------|--------|---------|-------------|
| {data type} | {service} | {automation} | {service} |
```

Save to: `.make/context/erd.md`

### Artifact 4 — system-design.md

Architecture overview of the full automation system:

```markdown
# Automation System Design

**Generated:** {date}

## Architecture Overview
{2-3 sentences describing the overall shape of the system}

## Trigger Inventory
| Automation | Trigger Type | Service | Frequency |
|------------|-------------|---------|-----------|
| {title} | Webhook/Schedule/Watch | {service} | {frequency} |

## Connection Requirements
| Service | Auth Type | Required For |
|---------|-----------|-------------|
| {service} | OAuth2/API Key/Webhook | {automation title(s)} |

## Data Stores Required
{List any persistent storage needs identified during interview}
- {purpose}: {what data, why it needs to persist}

## Automation Dependencies
{If any automation feeds into another, show the chain}
{auto-001} → produces data used by → {auto-002}

## Error Handling Strategy
{Overall approach: Telegram alerts, retry policy, fallback behavior}

## Monthly Cost Estimate
| Automation | Ops/Month | USD/Month |
|------------|-----------|-----------|
| {title} | ~{n} | ~${n} |
| **Total** | **~{n}** | **~${n}** |
```

Save to: `.make/context/system-design.md`

### Artifact 5 — stack.md

Complete tech requirements checklist:

```markdown
# Tech Stack Requirements

**Generated:** {date}
**Status:** Generated from discovery — verify during Bootstrap

## Make.com Apps Required

| App | Native Module? | Used By | Notes |
|-----|---------------|---------|-------|
| {service} | ✅ Yes | {automation} | |
| {service} | ❌ No — HTTP module needed | {automation} | Consider MCP server |

## MCP Servers Required

| MCP | Currently Available | Required For |
|-----|--------------------|----|
| make | Required | All automations |
| telnyx | Required (alerts) | Error notifications |
| {other} | Optional | {automation} |

## Connections to Set Up

| Service | Auth Type | Who Owns Credentials | Priority |
|---------|-----------|---------------------|----------|
| {service} | OAuth2 | {user/team} | Blocking |
| {service} | API Key | {user/team} | Blocking |

## Environment Variables Needed

```env
# Required
MAKE_API_KEY=
MAKE_TEAM_ID=
TELNYX_API_KEY=
TELEGRAM_CHAT_ID=

# For automations in this project
{SERVICE}_API_KEY=
{OTHER}_API_KEY=
```

## Data Stores to Create

| Name | Purpose | Schema |
|------|---------|--------|
| {name} | {what it stores} | {fields} |

## External APIs (Cost Impact)

| API | Free Tier | Paid Tier | Used By |
|-----|-----------|-----------|---------|
| {api} | {limit} | {cost} | {automation} |
```

Save to: `.make/context/stack.md`

---

### Artifact 6 — ai-agents.md (conditional — only if any automation has ai_required: true)

AI agent inventory for the project:

```markdown
# AI Agent Inventory

**Generated:** {date}
**Status:** Planned — design happens during System Design phase

## AI Agents in This Project

{for each automation with ai_required: true}

### {auto-id}: {title}

**Task type:** TBD — designed in Phase 2
**AI task:** {ai_task_description from intake}
**Trigger:** {trigger}
**Output destination:** {destination}
**Complexity estimate:** {Low/Medium/High}

**Design questions for Phase 2:**
- Which model is most appropriate for this task?
- Does the AI need tools (CRM lookup, web search, email)?
- Does it need memory across runs?
- Single-shot or loop?

**Status:** 📋 Planned
```

Save to: `.make/context/ai-agents.md`
Add to stack.md: AI provider(s) as required connections.

---

### Artifact Generation Summary

After all artifacts are written, confirm to user:
```
PROJECT ARTIFACTS GENERATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ context.md       — project context and goals
✅ prd.md           — full requirements document  
✅ erd.md           — data flow diagram
✅ system-design.md — architecture overview
✅ stack.md         — tech requirements checklist
{if ai_required automations exist:}
✅ ai-agents.md     — AI agent inventory ({n} AI automations)

All saved to .make/context/

Next: Bootstrap will map your workspace and check which
connections and MCPs are already set up.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Update `current-session.json` → `artifacts_generated: true`.

---

## Output Contract

Return to calling orchestrator:

```json
{
  "automations": [
    {
      "id": "auto-001",
      "title": "Short descriptive title",
      "trigger": "plain-language trigger description",
      "action": "plain-language action description",
      "destination": "where output goes",
      "frequency": "estimated frequency",
      "error_pref": "log_only | log_and_alert",
      "budget_monthly_usd": null,
      "complexity": "low | medium | high",
      "priority": 1,
      "status": "idea"
    }
  ],
  "total": 3,
  "portfolio_summary": "plain-language 2-sentence summary of the full portfolio"
}
```

---

## Portfolio Display Format

After the interview, display for user confirmation:

```
YOUR AUTOMATION PORTFOLIO ({n} automations)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] {title}                             [Low complexity]
    When {trigger}
    → {action}
    → Sent to: {destination}
    Frequency: {frequency}

[2] {title}                             [Medium complexity]
    ...

[3] {title}                             [High complexity]
    ...

Build order: [1] → [2] → [3]
Reason: Starting with the quickest win, then building toward the more complex ones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Does this list look right? Any changes before I start designing?
```

---

## Edge Cases

**User describes something Make.com can't do:**
```
Make.com doesn't support {X} natively. The closest option is {alternative}.
Shall I design it that way, or would you prefer to skip this one for now?
```

**User describes a duplicate of an existing scenario:**
```
You already have a scenario that does {X} (created {date}). 
Want me to modify that one instead, or build a separate version?
```

**User is vague:**
Ask one clarifying question at a time. Never ask more than two questions in one message.

**User doesn't know the frequency:**
```
No problem — I'll set it up with a daily schedule to start.
You can always change the timing later.
```
