# Telnyx Expert — Voice AI / AI Assistants

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Overview

Telnyx AI Assistants answer and make calls autonomously using a conversational AI
engine. They handle inbound calls, collect information, and transfer to humans.

---

## Creating an AI Assistant

```
mcp__telnyx__create_assistant
  name: "My AI Receptionist"
  voice: "Telnyx.Paige"          ← or "Telnyx.Marcus"
  language: "en-US"
  system_prompt: "..."            ← the assistant's instructions
  transfer_to: "+15141234567"     ← REQUIRED: human fallback
  end_call_phrases: ["goodbye", "thank you bye", "that's all"]
```

---

## Available Voice Models

| Voice | Gender | Style |
|-------|--------|-------|
| `Telnyx.Paige` | Female | Professional, warm |
| `Telnyx.Marcus` | Male | Professional, clear |

Third-party voices (ElevenLabs, Azure Neural) available via `voice_settings.voice_provider`.

---

## System Prompt Template

```
You are [Name], the virtual assistant for [Company Name].
Your role is to [purpose].

You can help callers with:
- [Task 1]
- [Task 2]
- [Task 3]

When a caller asks about something outside your scope, say:
"I'll connect you with a team member who can help with that." then transfer.

Always be professional, brief, and friendly.
End the call by asking: "Is there anything else I can help you with today?"
```

---

## AI Assistant Design Principles

- **Always set `transfer_to`** — every AI assistant must have a human fallback number
- **Define `end_call_phrases`** — without them, the assistant may not know when to hang up
- **Keep system_prompt under 500 words** — longer prompts increase latency
- **Test with your own number** before deploying — use `mcp__telnyx__start_assistant_call`
- **Handle "agent please"** — train the prompt to recognize escalation requests

---

## Routing Pattern in Make.com

```
[Webhook: call.initiated] → [Telnyx AI: start_assistant_call with assistant_id]
  → [Webhook: call.ai.gather] ← AI collects info, fires this event with transcript
  → [Your Make.com logic based on what caller said]
  → [Telnyx: speak or transfer]
```

---

## Managing Assistants

```
mcp__telnyx__list_assistants      — list all assistants
mcp__telnyx__get_assistant        — get assistant config
mcp__telnyx__get_assistant_texml  — get TeXML representation
mcp__telnyx__update_assistant     — modify live assistant (LEVEL 2 — requires approval)
mcp__telnyx__mcp_telnyx_delete_assistant  — delete (LEVEL 3 — irreversible)
```

---

## Common Issues

| Problem | Check |
|---------|-------|
| AI assistant silent | Check system_prompt length; verify voice model name exact spelling |
| Assistant doesn't hang up | Ensure `end_call_phrases` are defined and likely to be spoken |
| Caller not transferred | Verify `transfer_to` number is correct and reachable |
