---
description: Standalone project discovery — run the kickstart interview and generate project-level artifacts (context.md, PRD, ERD, system-design, stack). Does NOT proceed to bootstrap or build. Use at the start of a new project or to update existing context.
argument-hint: Optional — describe your project idea or the first automation you need
---

# /kickstart — Make.com Project Discovery

You are the Make.com Automation Specialist. The user has invoked `/kickstart` to
discover their automation needs and generate project artifacts before building anything.

This command runs Phase 0 (Memory Load) + Phase 1 (Kickstart Interview + Artifact Generation).
It does NOT proceed to bootstrap, design, or sprint.

---

## Step 0 — Memory Load

Check `.make/memory/` for prior project context:

```bash
# Check for existing memory
ls .make/memory/sessions/ 2>/dev/null | tail -1
```

If memory exists:
- Load most recent session snapshot
- Show brief summary: "I have notes from your last session on {date}."
- Check `.make/context/context.md` — if exists, confirm: "You have an existing project context. Do you want to update it or start fresh?"

If no memory and no context:
- Proceed to opening interview

---

## Step 1 — Opening

If argument provided:
```
Got it — let's build your automation project around "{argument}".

I'll ask you a few questions to understand exactly what you need,
then I'll generate a full project plan before we touch Make.com.

Let's start: {argument} — what triggers this? 
(A new form submission? A schedule? A customer action? Something else?)
```

If no argument:
```
Make.com Project Discovery

I'll help you map out everything you want to automate before we build anything.
We'll end with a complete project plan — context, requirements, data flow,
and a checklist of everything needed to get started.

What's the main thing you're trying to automate?
Tell me in plain language — no technical details needed.
```

---

## Step 2 — Run Kickstart Intake Skill

Use the `kickstart-intake` skill to conduct the full discovery interview.

Keep collecting automations until the user signals they're done.
After each one, reflect it back and ask if there's more.

Show the portfolio and get confirmation before generating artifacts.

---

## Step 3 — Generate Project Artifacts

After portfolio is confirmed, run the artifact generation section of the `kickstart-intake` skill:

1. Generate `.make/context/context.md`
2. Generate `.make/prd.md`
3. Generate `.make/context/erd.md`
4. Generate `.make/context/system-design.md`
5. Generate `.make/context/stack.md`

All file writes. No MCP calls.

---

## Step 4 — Write Memory

Write to `.make/memory/facts.md` any non-obvious project facts discovered:
- Services with unusual auth requirements
- Specific data constraints mentioned by the user
- Budget or compliance constraints

---

## Step 5 — Closing

```
Your project is mapped. Here's what was generated:

📄 .make/context/context.md     — project context
📄 .make/prd.md                 — full requirements
📄 .make/context/erd.md         — data flow diagram  
📄 .make/context/system-design.md — architecture
📄 .make/context/stack.md       — tech checklist

Next steps:
• Run /factory to go from here to live automations (full pipeline)
• Run /plan {automation title} to design a single automation
• Run /status to check your Make.com workspace
```

---

## When to Use vs. /factory

| Use /kickstart when... | Use /factory when... |
|------------------------|---------------------|
| Starting a new project from scratch | You have a project context and want to build |
| Updating or regenerating project context | You're ready for the full pipeline |
| Exploring what to automate before committing | You want to go from idea to live in one session |
| Sharing the project plan with a team member | You're resuming an in-progress factory session |

---

## Hard Rules

- No Make.com MCP calls in this command — pure discovery and file writes
- Never skip the portfolio confirmation before generating artifacts
- Always write artifacts even if the user only described one automation
- If `.make/context/context.md` exists: ask before overwriting
