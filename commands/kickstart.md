---
description: Project discovery — generates context artifacts from interview or existing scenarios. Does NOT build.
argument-hint: Optional — describe your project idea or the first automation
---

# /kickstart — Make.com Project Discovery

Phase 0 (Memory Load) + Phase 1 (Discovery + Artifact Generation).
Does NOT proceed to bootstrap, design, or sprint.

## Step 0 — Memory Load

Check `.make/memory/sessions/` for prior context.
If found: summarize and ask "Update existing context or start fresh?"

## Step 0.5 — Mode Selection

Ask the user:

```
Are you starting fresh, or do you have existing Make.com scenarios
to map, improve, or debug?

[1] New project — I'll interview you and build a plan from scratch
[2] Existing project — I'll read your current scenarios and reverse-engineer a project map
```

- If **[1] New project** → proceed to Step 1.
- If **[2] Existing project** → run `existing-scenario-discovery` skill, then jump to Step 3.

## Step 1 — Opening (new project only)

If argument provided: `"Got it — let's build around '{argument}'. What triggers this?"`
If no argument: `"What's the main thing you want to automate? Plain language is fine."`

## Step 2 — Intake (new project only)

Run `kickstart-intake` skill. Collect full portfolio, confirm before proceeding.

## Step 3 — Generate Artifacts

Run artifact generation from `kickstart-intake` skill:
1. `.make/context/context.md`
2. `.make/prd.md`
3. `.make/context/erd.md`
4. `.make/context/system-design.md`
5. `.make/context/stack.md`

File writes only — no MCP calls in this step.

## Step 4 — Write Memory

Append non-obvious facts discovered to `.make/memory/facts.md`.

## Step 5 — Closing

```
Your project is mapped. Files generated in .make/context/

Next steps:
• /factory  — full pipeline: bootstrap → design → build
• /plan {title}  — design a single automation
• /status  — check your Make.com workspace
```

## Hard Rules

- No Make.com MCP calls except inside `existing-scenario-discovery` skill
- Never skip portfolio confirmation before writing artifacts
- If `.make/context/context.md` exists: ask before overwriting
