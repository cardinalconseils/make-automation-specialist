# Scenario Orchestrator — Phase -1 and Phase 0a-0b: Session + Direction

For Phase 0c (Portfolio Review + Stakes Check), see `scenario-orchestrator-kickstart.md`.
For Phase 1 (Bootstrap), see `scenario-orchestrator-bootstrap.md`.

## Phase -1 — MEMORY LOAD

Before anything else, load project memory using the `memory` skill.

```bash
ls .make/memory/sessions/ 2>/dev/null | sort | tail -1
```

If a session file exists:
- Read the most recent session snapshot
- Display: "Last session: {date} — {one-line summary from snapshot}"
- If `.make/context/context.md` exists: load project context (domain, goals, integrations)

If no memory exists: proceed silently.

**Note:** Memory load is deterministic — file reads only, no MCP calls.

---

## Phase 0 — KICKSTART: Discover the Automation Portfolio

Goal: understand ALL the automations the user needs before designing any of them.

### 0a — Load the Factory Session

Check if `.make/factory/current-session.json` exists and is from today.
- If yes: restore state, show progress, ask if user wants to continue or restart.
- If no: create a new session file.

Session file fields: `session_id` (YYYY-MM-DD-HHmm), `status`
(kickstart|bootstrap|design|sprint|complete), `automations` array (id, title, trigger,
action, destination, frequency, priority, complexity: low|medium|high, status:
idea|designed|approved|built|verified), `workspace_mapped`, `design_approved`,
`sprint_complete`.

### 0b — Mode Selection

**Before the interview, always ask:**

```
Are you starting a new project, or do you have existing Make.com scenarios
you want to map, improve, or debug?

[1] New project — I'll interview you and build a plan from scratch
[2] Existing project — I'll read your current scenarios and reverse-engineer a project map
```

- **[1] New project** → proceed to Gate 0 below.
- **[2] Existing project** → run `existing-scenario-discovery` skill to fetch and translate
  live scenarios, then skip directly to Portfolio Review in `scenario-orchestrator-kickstart.md`.

### Gate 0 — Direction Check (deterministic, new project only)

**Direction present** (proceed to 0b-ii):
- Provided a seed automation (e.g., `/factory automate our lead intake`)
- Described trigger + action + destination
- Said "I want to automate X" / "I need a scenario that does Y"

**No direction** (route to brainstorm-sharp):
- "I want to automate something but don't know what"
- "I need to be more efficient" / "I'm wasting time on [vague area]"
- "What should I automate?" / "Help me figure out what to build"
- ≤ 2 sentences with no trigger, action, or destination

→ **No direction:** Load `brainstorm-sharp` skill. Run it. After direction locked:
  - **Simple** (single trigger → action → destination): proceed to 0b-ii
  - **Complex** (multi-step, unclear data shapes): load `discovery-to-blueprint` skill.
    Run intake (one question at a time). Feed context into kickstart-intake, then 0c.

→ **Direction present:** Skip brainstorm-sharp. Proceed to 0b-ii immediately.

**This gate is deterministic — no direction = must run brainstorm-sharp. No skip path.**

### 0b-ii — Opening Interview (new project only)

Open with a welcome message explaining the four-phase factory approach, then ask:
"What's the main thing you're trying to automate? Tell me in plain language."

Use the kickstart-intake skill. Questions (conversational, not all at once):
1. "What triggers this?" (form, email, schedule, manual, another system?)
2. "What should happen as a result?"
3. "Where does the result go?"
4. "How often does this run?"
5. "Is there anything else you wish was automated in your business?"

After each automation: confirm and add to portfolio, then ask if there are more.

Continue in `scenario-orchestrator-kickstart.md` for Portfolio Review and Stakes Check.
