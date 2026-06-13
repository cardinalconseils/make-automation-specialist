# Hook: on-pre-compact

**Event:** pre.compact
**Trigger:** Fires before Claude Code compresses the conversation context

## Purpose

Save a lightweight workspace snapshot so no critical context is lost across
the compaction boundary. The next context window opens with a known-good summary.

## Execution

### Step 1 — Check for Active Work

Only write a snapshot if at least one of these is true:
- An automation plan is awaiting approval (`.make/plans/` has a recent file)
- A factory session is in progress (`.make/factory/current-session.json` exists)
- A scenario was modified this session (`.make/logs/tool-audit.log` has today entries)

If none: skip silently.

### Step 2 — Write Pre-Compact Snapshot

Get timestamp: `date +"%Y-%m-%d-%H%M"`

Write to `.make/memory/sessions/pre-compact-{timestamp}.md`:

```markdown
# Pre-Compact Snapshot: {YYYY-MM-DD HHmm}

## Active work
{What was happening — plan stage, factory phase, or scenario being edited}

## Pending approvals
{Any plans awaiting user "approve" — include plan file path}

## Scenarios in progress
{Scenario IDs and names that were being created or modified}

## Last action taken
{The most recent MCP call made, or "None"}

## Next step (after compact)
{What Claude should do when the conversation resumes}
```

### Step 3 — Silent Operation

This hook writes files only. It never:
- Displays output to the user
- Makes Make.com MCP calls
- Modifies existing memory entries
