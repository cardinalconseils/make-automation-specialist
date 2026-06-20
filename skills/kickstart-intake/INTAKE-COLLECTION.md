# Intake: Per-Automation Data Collection

Part of `kickstart-intake`. Called from `INTAKE-QUESTIONS.md`.

---

## Fields to Collect

| Field | Question | Required? |
|-------|----------|-----------|
| `trigger` | "What starts this off?" | Yes |
| `action` | "What should happen as a result?" | Yes |
| `destination` | "Where does the result go?" | Yes |
| `frequency` | "How often does this run?" | Yes |
| `error_pref` | "If something goes wrong — log quietly or alert you?" | No (default: log + alert) |
| `budget` | "Any monthly cost limit to stay within?" | No |
| `ai_required` | Detected automatically (see AI Detection below) | Auto |

---

## Reflection and Confirmation

After collecting trigger + action + destination:

```
Got it — so when {trigger}, you want me to {action} and send it to {destination}.
{If frequency unclear}: About how often does this happen?
```

Then confirm:

```
Adding this to your portfolio. Anything to change about that description?
```

---

## AI Agent Detection

Scan the user's description for AI signals after collecting trigger + action + destination.

**Signal phrases:** "AI", "ChatGPT", "Claude", "GPT", "Gemini", "LLM", "language model",
"summarize", "classify", "generate text", "write a", "draft a", "decide", "analyze and",
"intelligently", "smart", "automatically determine", "extract from", "parse",
"understand the meaning", "respond to", "chatbot", "virtual assistant", "AI agent",
"autonomous"

**If any signal detected:**

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
