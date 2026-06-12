# Hook: on-session-end

**Event:** session.stop
**Trigger:** Fires when the Claude Code session ends (user closes, /exit, context limit)

## Purpose

Write a session memory snapshot to `.make/memory/sessions/` so the next session
can see what was done. Also appends any new decisions or gotchas discovered during
the session to the persistent memory files.

This hook is silent — it does NOT surface messages to the user.
If nothing happened this session, it writes nothing.

---

## Step 1 — Determine If Session Had Meaningful Activity

Check whether any of the following occurred this session:
- A Make.com MCP call was made (check `.make/logs/tool-audit.log` for today's entries)
- A scenario was created, modified, or activated
- An audit was run
- A factory phase was completed
- A plan was generated

If none of the above: skip this hook entirely. Do not write an empty session file.

---

## Step 2 — Collect Session Summary

Gather from the session:

1. **What was done** — which commands ran, which automations were touched
2. **Scenarios affected** — IDs and names of any scenarios created/modified/activated
3. **Factory phase** — if a factory session was active, what phase it ended in
4. **New memory items** — any facts, decisions, or gotchas worth recording

---

## Step 3 — Write Session Snapshot

Get current timestamp: `date +"%Y-%m-%d-%H%M"`

Write to `.make/memory/sessions/{timestamp}.md`:

```markdown
# Session: {YYYY-MM-DD HHmm}

## What was done
{1-3 bullet points — commands run, automations built/designed/audited}

## Scenarios affected
{List with IDs if known, or "None" if no scenario changes}

## Factory session
{Phase reached, session ID if factory was active — or "Not a factory session"}

## New memory written
{List any new entries added to facts/decisions/gotchas — or "None"}

## Next steps (if known)
{What was left unfinished, or "—" if complete}
```

---

## Step 4 — Append New Memory (if any)

If the session surfaced anything worth remembering:

**Decisions** (architecture choices made this session):
- Append to `.make/memory/decisions.md` in `## [YYYY-MM-DD] Title` format

**Gotchas** (issues or surprises encountered):
- Append to `.make/memory/gotchas.md` in `## [YYYY-MM-DD] Title` format

**Facts** (new non-obvious integration knowledge):
- Append to `.make/memory/facts.md` in `## [YYYY-MM-DD] Title` format

Use the `memory` skill write protocol for format and append rules.

---

## Step 5 — Ensure Memory Files Exist

If `.make/memory/` directory doesn't exist yet, create it silently.

Initialize any missing memory files with an empty header:

```markdown
# Make.com Project Memory — {facts|decisions|gotchas}
<!-- Append-only. Never delete entries. Format: ## [YYYY-MM-DD] Title -->
```

---

## Silent Operation

This hook writes files only. It never:
- Displays output to the user
- Makes Make.com MCP calls
- Modifies existing memory entries (append-only)
- Overwrites the session file if one exists for the same timestamp

---

## What This Hook Does NOT Do

- Send Telegram alerts (that's alert-dispatcher's job)
- Write execution logs (that's execution-logger's job)
- Update `.make/factory/current-session.json` (that's sprint-runner's job)
