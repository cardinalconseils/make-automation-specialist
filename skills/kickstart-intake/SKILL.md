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
