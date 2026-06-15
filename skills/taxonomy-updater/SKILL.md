---
name: taxonomy-updater
description: "Add new failure patterns to the Make Failure Taxonomy. Ensures correct categorization, consistent format, and changelog entry. Use after diagnosing a failure not currently in the taxonomy."
allowed-tools: Read, Write, Edit
---

# Taxonomy Updater Skill

## File
`taxonomy/make-failure-taxonomy.md`

## Entry Format (strict)

```markdown
### {PREFIX}-{NNN} — {Title}
- **Symptom:** {exact error or observable behavior}
- **Root cause:** {specific technical reason Make behaves this way}
- **Fix:** {actionable steps}
- **Make note:** {optional — only if adds Make-specific nuance}
```

## Steps
1. Read the full taxonomy
2. Choose prefix (see table below)
3. Find next available number in that category
4. Insert in the correct section
5. Add changelog entry:
   ```
   | {YYYY-MM-DD} | Added {CODE}: {Title} | {source} |
   ```

## Prefix Selection

| Situation | Prefix |
|-----------|--------|
| HTTP status code from any module | `HTTP-` |
| Make engine error type (DataError, etc.) | `MAKE-` |
| OAuth, token, connection break | `CONN-` |
| Wrong type, null, format, empty | `DATA-` |
| Trigger/webhook/schedule didn't fire | `TRIG-` |
| 429, ops quota, data transfer | `RATE-` |
| Timeout, parallel conflict, ops limit | `EXEC-` |
| Router wrong path, filter wrong | `ROUTER-` |
| Iterator empty, aggregator bad output | `ITER-` |
| isinvalid: true, module ID mismatch | `BLUEPRINT-` |
| App-specific (Slack, Google, Airtable) | `APP-` |
| Architectural pattern across scenarios | `PATTERN-` |

## Quality Gate
Every entry must have:
- Symptom specific enough to recognize in the field
- Root cause that explains WHY (not just what)
- Fix that is actionable (not "check settings")

Do NOT add:
- Vague entries ("something goes wrong")
- Duplicates — merge instead
- General programming advice unrelated to Make
