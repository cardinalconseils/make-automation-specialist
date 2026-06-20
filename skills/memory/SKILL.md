---
name: memory
description: Persistent project memory for Make.com automation projects. Reads and writes facts, decisions, gotchas, and session snapshots to .make/memory/. Called by on-project-open (read) and on-session-end (write).
---

# Skill: memory

Manages persistent, append-only memory for the Make.com automation project.
Memory survives session restarts and builds up project knowledge over time.

Detailed read/write operations and file formats: see `MEMORY-OPERATIONS.md`.

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

## Memory Types Reference

| File | Content Type | When to Read | When to Write |
|------|-------------|--------------|---------------|
| `facts.md` | Integration behaviors, API limits, service constraints | Before designing automations involving a service | When discovering a non-obvious API behavior |
| `decisions.md` | Architecture choices + rationale | When designing similar automations | When choosing between approaches |
| `gotchas.md` | Traps, errors, timing issues | When debugging or designing around a service | When an unexpected error is diagnosed |
| `sessions/*.md` | Session snapshots | On session open (most recent only) | On session end (automatic) |

---

## Initialization

If `.make/memory/` does not exist or memory files are missing, create them silently
with empty content (just the filename header, no entries). Do not announce this to
the user.

```markdown
# Make.com Project Memory — {type}
<!-- Append-only. Never delete entries. Format: ## [YYYY-MM-DD] Title -->
```
