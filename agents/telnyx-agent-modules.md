# Telnyx Agent — Module Patterns and Phase Details

Continuation of `agents/telnyx-agent.md`.

---

## Phase 0 — Account Discovery (always run first)

Run these reads in parallel to build context:

```
mcp__telnyx__list_phone_numbers       → owned numbers
mcp__telnyx__list_messaging_profiles  → SMS routing config
mcp__telnyx__list_call_control_applications → voice routing config
mcp__telnyx__list_connections         → connection types
mcp__telnyx__list_assistants          → existing AI assistants
```

Display account status card:
```
TELNYX ACCOUNT STATUS
──────────────────────
Phone numbers:      [count] ([list of numbers])
Messaging profiles: [count]
Call control apps:  [count]
Connections:        [count]
AI assistants:      [count]
──────────────────────
```

If any resource is missing for the user's goal, note it and offer to create it.

---

## Phase 1 — Intent Discovery

Ask one focused question to understand what the user wants to accomplish.
Do not ask multiple questions at once.

Route to the appropriate flow based on intent:

| Intent | Flow |
|--------|------|
| Send SMS | SMS outbound flow |
| Receive SMS / two-way SMS | Inbound SMS setup flow |
| SMS campaign / bulk | 10DLC compliance check first |
| Make phone calls | Voice outbound flow |
| Receive phone calls | Voice inbound flow |
| IVR / phone menu | IVR flow (TeXML or Call Control) |
| AI receptionist / voice bot | AI Assistant flow |
| SIP trunk / PBX | SIP Trunking flow |
| Call recording | Recording setup flow |
| Buy/manage numbers | Number management flow |
| WebRTC / browser calling | WebRTC flow |
| Number lookup | Number Intelligence flow |

---

## Phase 2 — Plan with Costs

Present a plan before executing: what will change, numbers/profiles/connections involved, estimated monthly cost, and risk notes. Use the standard PLAN SUMMARY format from CLAUDE.md.

---

## Phase 3 — Execute with Narration

After approval:
1. Run account discovery reads again to get fresh IDs
2. Announce each MCP call before making it: "Creating messaging profile..."
3. Apply approval gates (see Section 13 of telnyx-expert skill) before Level 2/3 actions
4. After each step, confirm success with the response data
5. Run a test (send test SMS or test call to user's own number)

---

## Phase 4 — Test and Validate

Every setup ends with a test:
- SMS setup: send a test message to the user's own mobile number
- Voice setup: make a test call to the user's own number
- AI assistant: use `start_assistant_call` to call the user's own number
- Only declare success after the user confirms the test worked

---

## Phase 5 — Log

Write to `.make/logs/telnyx-{YYYY-MM-DD}.md`: action taken, numbers involved, profiles/connections created, test result, cost impact.

---

## CLI + Error Handling

**Local testing:** `brew install telnyx-cli` → `telnyx login` → `telnyx webhook listen --port 3000` → use tunnel URL. See Section 12 of telnyx-expert skill.

**API errors:** Translate using `skills/personas/telnyx-consultant.md`. If `TELNYX_API_KEY` is missing, direct user to telnyx.com → Auth → API Keys, set the env var, and restart.
