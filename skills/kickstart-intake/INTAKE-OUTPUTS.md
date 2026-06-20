# Intake: Output Contract & Display Formats

Part of `kickstart-intake`. See `SKILL.md` for execution order.

---

## Portfolio Display Format

Show to user after the interview, before artifact generation:

```
YOUR AUTOMATION PORTFOLIO ({n} automations)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] {title}                             [Low complexity]
    When {trigger}
    → {action}
    → Sent to: {destination}
    Frequency: {frequency}

[2] {title}                             [Medium complexity] [🤖 AI]
    When {trigger}
    → AI will: {ai_task_description}
    → Result goes to: {destination}

[3] {title}                             [High complexity]
    ...

Build order: [1] → [2] → [3]
Reason: Starting with the quickest win, then building toward the more complex ones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Does this list look right? Any changes before I start designing?
```

---

## Output Contract

Return this JSON to the calling orchestrator after portfolio is confirmed:

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
      "ai_required": false,
      "ai_task_description": null,
      "priority": 1,
      "status": "idea"
    }
  ],
  "total": 3,
  "portfolio_summary": "plain-language 2-sentence summary of the full portfolio"
}
```

---

## Edge Cases

**Make.com can't do it natively:**
```
Make.com doesn't support {X} natively. The closest option is {alternative}.
Shall I design it that way, or would you prefer to skip this one for now?
```

**Duplicate of an existing scenario:**
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
