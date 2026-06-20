# Memory Operations — Read & Write Protocols

Companion to `SKILL.md`. Defines all read and write procedures for `.make/memory/`.

## Read Protocol

### On Session Open

Check for memory files and surface to user:

```bash
ls -t .make/memory/sessions/*.md 2>/dev/null | head -1
grep "^## \[20" .make/memory/decisions.md 2>/dev/null | tail -5
grep -c "^## \[20" .make/memory/facts.md 2>/dev/null
grep -c "^## \[20" .make/memory/gotchas.md 2>/dev/null
```

Display summary if memory exists:
```
PROJECT MEMORY LOADED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Last session: {date} — {one-line summary from session file}
Facts on file: {n}    Decisions on file: {n}    Gotchas on file: {n}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no memory exists: show nothing (first session).

### Targeted Lookup (Token-Efficient)

Never load full memory files into context. Use grep-first lookups:

```bash
grep -A4 "HubSpot" .make/memory/gotchas.md
grep -A4 "webhook" .make/memory/decisions.md
grep -A4 "Stripe"  .make/memory/facts.md
```

Only read the full file if grep finds a relevant entry AND more context is needed.

## Write Protocol

### When to Write

**facts.md** — non-obvious API behavior, rate limit, quota, undocumented quirk.

**decisions.md** — architecture choice made, module selected over an alternative,
cost-vs-capability tradeoff resolved.

**gotchas.md** — non-obvious error diagnosed, timing/ordering issue found, service
behaves differently than documented.

**Do NOT write:** routine execution logs (→ `.make/logs/`), scenario blueprints
(→ `.make/scenarios/`), things already in `.make/workspace.json`, obvious facts.

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
