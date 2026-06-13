# Hook: on-session-end

**Event:** session.stop
**Trigger:** Fires when the Claude Code session ends

## Purpose

Write a session memory snapshot and extract structured learnings (facts, decisions,
gotchas) so the next session opens with full context.

---

## Step 1 — Check for Meaningful Activity

Skip this hook entirely if NONE of these occurred:
- A Make.com MCP call was made (check `.make/logs/tool-audit.log` for today)
- A scenario was created, modified, or activated
- An audit was run
- A factory phase completed

---

## Step 2 — Write Session Snapshot

Timestamp: `date +"%Y-%m-%d-%H%M"`

Write to `.make/memory/sessions/{timestamp}.md`:

```markdown
# Session: {YYYY-MM-DD HHmm}

## What was done
{1-3 bullets — commands run, automations built/designed/audited}

## Scenarios affected
{List with IDs, or "None"}

## Factory session
{Phase reached, or "Not a factory session"}

## New memory written
{List entries added to facts/decisions/gotchas, or "None"}

## Next steps
{What was left unfinished, or "—"}
```

---

## Step 3 — Extract Structured Learnings

After writing the snapshot, review the session for new knowledge:

**Decisions** — architecture choices made (trigger type, data model, connection):
- Append to `.make/memory/decisions.md` as `## [YYYY-MM-DD] Title`

**Gotchas** — surprises, API quirks, timing issues, unexpected behaviors:
- Append to `.make/memory/gotchas.md` as `## [YYYY-MM-DD] Title`

**Facts** — non-obvious integration knowledge (rate limits, payload shapes, auth flows):
- Append to `.make/memory/facts.md` as `## [YYYY-MM-DD] Title`

Only write entries for genuinely new knowledge. Skip if nothing new was discovered.

---

## Step 4 — Ensure Memory Files Exist

If `.make/memory/` files are missing, initialize with:

```markdown
# Make.com Project Memory — {facts|decisions|gotchas}
<!-- Append-only. Never delete entries. Format: ## [YYYY-MM-DD] Title -->
```

---

## Silent Operation

This hook writes files only. Never makes MCP calls. Never overwrites existing entries.
