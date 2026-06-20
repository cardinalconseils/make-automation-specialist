# Changelog Entry Format

Append to `.make/changelog/{scenario-id}.md` after every fix.

```markdown
## {YYYY-MM-DD HH:MM} — {change-type}

**Agent:** scenario-auditor
**Approved by:** User (session {date})
**Execution log:** `.make/logs/{log-filename}`

### Issue Fixed
{Plain-language description of the problem that was fixed}

### What Changed

**Before:**
{Relevant before state — plain language + key config values}

```json
{minimal before JSON snippet if useful}
```

**After:**
{Relevant after state — plain language + key config values}

```json
{minimal after JSON snippet if useful}
```

### Outcome
{success | failed}
{Description of outcome}

---
```
