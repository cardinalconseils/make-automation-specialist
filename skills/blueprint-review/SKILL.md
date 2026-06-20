---
name: blueprint-review
description: "Pre-push blueprint JSON review for Make.com scenarios. Checks structural integrity, connection IDs, mapper references, filter logic, and error handler coverage before any scenario_update call."
allowed-tools: Read, Grep, mcp__claude_ai_Make__validate_blueprint_schema, mcp__claude_ai_Make__connections_list, mcp__claude_ai_Make__validate_module_configuration
---

# Make Blueprint Review Skill

## Purpose
Review a Make.com blueprint JSON before pushing it via the API. Catch structural issues that cause `isinvalid: true` or silent runtime failures.

## Review Checklist

### 1. JSON Structure
- [ ] Valid JSON (no syntax errors)
- [ ] `"id"` present at top level
- [ ] `"flow"` array present and non-empty
- [ ] All module `"id"` values are unique integers

### 2. Flow Integrity
- [ ] Every ID in `"flow"` references an existing module
- [ ] Every ID in `"routes"` references an existing module
- [ ] `"next"` field points to valid module ID (or absent for terminal)
- [ ] Router routes ordered: specific first, fallback last

### 3. Connections
- [ ] All `"connection"` objects have `"id"` field
- [ ] Connection IDs exist in the target account (verify via MCP)
- [ ] Correct connection type per module (e.g., `google-vertex-ai` ≠ generic Google)

### 4. Mapper Expressions
- [ ] All `{{moduleId.field}}` use valid module IDs
- [ ] No references to removed/renamed modules
- [ ] Semicolons as separators (not commas): `if(cond; a; b)`
- [ ] 1-based array indexing: `{{array[1]}}` not `{{array[0]}}`
- [ ] No JS syntax: no ternary `? :`, no `.method()` calls

### 5. Data Mapping Safety
- [ ] `ifempty()` on optional fields
- [ ] Explicit type conversions where needed
- [ ] Date fields include timezone parameter

### 6. Error Handling
- [ ] Error handlers on HTTP/API modules
- [ ] No module uses `Ignore` when output is required downstream
- [ ] Transactional flows use `Rollback` or compensation pattern

### 7. Router/Filter
- [ ] Fallback route on every router
- [ ] No blank filter operands
- [ ] Filter logic matches intent (AND between rows, OR within row)

## Output Format

```markdown
## Blueprint Review — {scenario name/id}

### ✅ Passed
- {check}: {note}

### ⚠️ Warnings (risky but won't necessarily fail)
- {check}: {explanation}

### ❌ Issues (will cause isinvalid: true or runtime failure)
- {check}: {explanation} → Fix: {fix}

### Verdict
{PUSH / FIX FIRST / NEEDS HUMAN REVIEW}
```

## After Review

### Write sentinel (required for push guard)
After completing the review — regardless of verdict — write the sentinel so the
deterministic `pre-push-guard` hook knows this review happened:

```bash
mkdir -p .make/logs && touch .make/logs/.blueprint-reviewed
```

Without this file, the pre-push-guard hook will block all curl PUT calls.

### Continue
If issues found → fix before calling `mcp__claude_ai_Make__scenarios_update`.
If clean → proceed and check `"isinvalid": false` in response.

## Escalation

If an issue in the blueprint is not directly fixable (unknown root cause, connection account mismatch, obscure mapper behavior):
- Load `skills/failure-diagnostician/SKILL.md` — classify the issue against the taxonomy
- If it matches a known pattern: cite the code and apply the taxonomy fix
- If it's a new pattern: flag it and route to taxonomy-curator agent
