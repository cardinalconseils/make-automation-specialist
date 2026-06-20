---
name: execution-logger
description: Writes timestamped execution logs and changelog entries after every automation action. Called by post-execute hook. Append-only — never overwrites the audit trail.
---

# Skill: execution-logger

Writes timestamped logs after every execution. Called by post-execute hook.
Also writes changelog entries after scenario fixes.

See [log-format.md](log-format.md) for the execution log template.
See [changelog-format.md](changelog-format.md) for the changelog entry template.

## Append-Only Rule

Changelog files are NEVER overwritten. Always append. The changelog is an audit trail.

## File Naming

Log files: `{YYYY-MM-DD}-{HHmm}-{scenario-slug}.md`
Example: `2026-06-09-1441-lead-intake-crm.md`

Slugify scenario name: lowercase, spaces to hyphens, remove special characters.
Max 40 characters for the slug portion.

## Directory Creation

If `.make/logs/` or `.make/changelog/` directories don't exist, create them before writing.
Same for all `.make/` subdirectories.
