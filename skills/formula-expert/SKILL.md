---
name: formula-expert
description: "Make.com built-in functions, expression syntax, and module field expression patterns"
allowed-tools: Read, Grep, Glob
---

# Formula Expert Skill

Load this skill before writing any Make.com module field expressions.
It is the authoritative reference for Make.com built-in functions and expression syntax.

## Sub-files

- `FORMULAS-SYNTAX.md` — Expression syntax fundamentals (operators, nesting, references)
- `FORMULAS-TEXT.md` — Text functions + encoding/hashing/regex
- `FORMULAS-MATH.md` — Math functions
- `FORMULAS-DATE.md` — Date and time functions + format codes
- `FORMULAS-ARRAY.md` — Array, collection, logic, and data parsing functions
- `FORMULAS-EXAMPLES.md` — Ready-to-use patterns, OCR integration, gotchas summary

## Quick Reference

**Argument separator:** SEMICOLONS, not commas — `{{fn(a; b)}}` not `{{fn(a, b)}}`

**Item references:**
```
{{1.fieldName}}       — field from module 1
{{1.address.city}}    — nested field
{{1.items[].price}}   — array item field
```

**String concat:** `{{1.firstName & " " & 1.lastName}}`

**Top gotchas:**
| Gotcha | Wrong | Correct |
|--------|-------|---------|
| `now` has no parens | `{{now()}}` | `{{now}}` |
| Semicolons, not commas | `{{fn(a, b)}}` | `{{fn(a; b)}}` |
| substring is 0-indexed | `{{substring(x; 1; 1)}}` | `{{substring(x; 0; 1)}}` |
| Regex not quoted | `{{replace(x; "/\d/g"; "")}}` | `{{replace(x; /\d/g; "")}}` |
| Divide-by-zero guard | `{{divide(1.a; 1.b)}}` | `{{if(1.b = 0; 0; divide(1.a; 1.b))}}` |
| `contains` is case-sensitive | `{{contains(1.status; "Active")}}` | `{{contains(lower(1.status); "active")}}` |
