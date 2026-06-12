---
name: memory
description: Persistent project memory for Make.com automation projects. Reads and writes facts, decisions, gotchas, and session snapshots to .make/memory/. Called by on-project-open (read) and on-session-end (write).
---

# Skill: memory

Manages persistent, append-only memory for the Make.com automation project.
Memory survives session restarts and builds up project knowledge over time.

## Deterministic Classification — File I/O Only

This skill makes ZERO Make.com MCP calls. All operations are file reads and writes.

**Permitted operations:**
- Read (`.make/memory/` files)
- Write / Edit (append to memory files)
- Bash (grep-based lookups)

**BLOCKED operations:**
- Any `mcp__claude_ai_Make__*` tool call

---

## Memory Structure

```
.make/memory/
  facts.md        ← immutable project truths (integrations, constraints, API behaviors)
  decisions.md    ← architecture/automation decisions with rationale
  gotchas.md      ← traps, timing issues, non-obvious behaviors per service
  sessions/
    YYYY-MM-DD-HHmm.md  ← one snapshot per session
```

---

## Entry Format

All memory files use append-only dated headers. Never overwrite. Never delete.

```markdown
## [YYYY-MM-DD] Short Title

{2-4 lines of content}
```

---

## Read Protocol

### On Session Open

Check for memory files and surface to user:

```bash
# Most recent session
ls -t .make/memory/sessions/*.md 2>/dev/null | head -1

# Recent decisions (last 5 headers)
grep "^## \[20" .make/memory/decisions.md 2>/dev/null | tail -5

# Count of facts and gotchas
grep -c "^## \[20" .make/memory/facts.md 2>/dev/null
grep -c "^## \[20" .make/memory/gotchas.md 2>/dev/null
```

Display summary if memory exists:
```
PROJECT MEMORY LOADED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Last session: {date} — {one-line summary from session file}
Facts on file: {n}
Decisions on file: {n}
Gotchas on file: {n}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no memory exists: show nothing (first session).

### Targeted Lookup (Token-Efficient)

Never load full memory files into context. Use grep-first lookups:

```bash
# Find gotchas about a specific service
grep -A4 "HubSpot" .make/memory/gotchas.md

# Find decisions about a topic
grep -A4 "webhook" .make/memory/decisions.md

# Find facts about an integration
grep -A4 "Stripe" .make/memory/facts.md
```

Only read the full file if grep finds a relevant entry AND more context is needed.

---

## Write Protocol

### When to Write

**Write to facts.md when:**
- You discover a non-obvious behavior of a Make.com app or external API
- An integration has a specific rate limit, quota, or constraint worth remembering
- A connection type has an undocumented quirk

**Write to decisions.md when:**
- A meaningful architecture choice was made (e.g., chose polling over webhook for a reason)
- A module was selected over an alternative for a specific reason
- A cost-vs-capability tradeoff was resolved

**Write to gotchas.md when:**
- An error was encountered that non-obvious to diagnose
- A timing or ordering issue was found
- A service behaves differently than documented

**Do NOT write:**
- Routine execution logs (those go to `.make/logs/`)
- Scenario blueprints (those go to `.make/scenarios/`)
- Things already in `.make/workspace.json`
- Obvious information any developer would know

### Write Format

Append to the relevant file. Never overwrite. Use today's date.

```markdown

## [YYYY-MM-DD] {Short descriptive title}

{2-4 lines explaining the fact/decision/gotcha.}
{Be specific — name the service, the module, the constraint.}
{Include: what you discovered, why it matters, what to do about it.}
```

### Session Snapshot

At session end, write to `.make/memory/sessions/YYYY-MM-DD-HHmm.md`:

```markdown
# Session: {YYYY-MM-DD HHmm}

## What was done
{1-3 bullet points: automations built/designed/audited, commands run}

## Key outcomes
{Scenarios created, modified, or deleted. IDs if known.}

## New memory written
{List any facts/decisions/gotchas added this session. "None" if nothing new.}

## Next steps (if any)
{What was left unfinished, if anything.}
```

---

## Memory Types Reference

| File | Content Type | When to Read | When to Write |
|------|-------------|--------------|---------------|
| `facts.md` | Integration behaviors, API limits, service constraints | Before designing automations involving a service | When discovering a non-obvious API behavior |
| `decisions.md` | Architecture choices + rationale | When designing similar automations | When choosing between approaches |
| `gotchas.md` | Traps, errors, timing issues | When debugging or designing around a service | When an unexpected error is diagnosed |
| `sessions/*.md` | Session snapshots | On session open (most recent only) | On session end (automatic) |

---

## Initialization

If `.make/memory/` does not exist or memory files are missing, create them silently with empty content (just the filename header, no entries). Do not announce this to the user.

```markdown
# Make.com Project Memory — {type}
<!-- Append-only. Never delete entries. Format: ## [YYYY-MM-DD] Title -->
```
