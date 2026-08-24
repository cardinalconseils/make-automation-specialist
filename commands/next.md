---
description: Build the next unbuilt scenario from the project backlog. Same as /build, but picks the next item for you instead of asking.
argument-hint: None
---

# /next — Build the Next Backlog Item

Dispatch to the **scenario-builder** agent.

Identical to `/build` in every respect except selection: instead of showing the
backlog and asking, pick the **first item in `.make/context/prd.md` that has not
yet been built**, and go straight to the approval gate for that one scenario.

Determine "not yet built" by comparing the backlog against
`mcp__claude_ai_Make__scenarios_list` — never by memory, and never by trusting a
previous session's notes.

If every backlog item already exists, say so plainly and stop. Do not invent
additional work; offer `/audit` or `/status` instead.

The approval gate, the build phase and the report are exactly as described in
`commands/build.md`. Do not duplicate that logic here — follow it.
