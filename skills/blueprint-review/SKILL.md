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

### Write sentinel (required — both write paths are gated on it)
After completing the review — regardless of verdict — record it. Save the exact blueprint
you reviewed to a file, then:

```bash
# Resolve the plugin root: env var when running as an installed plugin, dev clone otherwise.
PR="${CLAUDE_PLUGIN_ROOT:-$HOME/Documents/DEV/make.com}"
node "$PR/scripts/blueprint-sentinel.js" <blueprint.json> "<VERDICT>" "<scenario name or id>"
```

If neither path resolves, find it: the script sits next to `pre-execute-gates.js`, whose
location is in the `PreToolUse` hook command in your `settings.json`.

VERDICT is your verdict line: `PUSH`, `FIX FIRST`, or `NEEDS HUMAN REVIEW`.

The script writes `.make/logs/.blueprint-reviewed` as JSON — timestamp, verdict, and the
**sha256 of the blueprint you reviewed**. Two deterministic hooks read it:

- `pre-execute-hook.js` blocks `scenarios_create` / `scenarios_update` unless that hash
  matches the blueprint actually being pushed.
- `pre-push-guard.js` blocks curl PUT unless the sentinel is fresh and not `FIX FIRST`.

Always write the sentinel with the script, never by hand — it uses the same canonical
hash the gate computes, so the two can never disagree. Hand-writing the JSON with a
guessed hash will block the push.

**Consequences of the hash binding:**
- Change one byte of the blueprint after reviewing → the gate blocks. Re-review.
- A `FIX FIRST` verdict blocks the push outright. Fix, then re-review.
- The sentinel expires after 24h.

### Continue
If issues found → fix, then **re-review and re-write the sentinel** before calling
`mcp__claude_ai_Make__scenarios_update`. The sentinel is bound to the old bytes; a fixed
blueprint needs a fresh one.
If clean → proceed and check `"isinvalid": false` in response.

### On a `hybrid` routing verdict
Also confirm the AI Agent module returns **structured output**, and that downstream
filters/routers read that structure rather than raw model text. Routing on free text is
the most common way a hybrid scenario becomes non-reproducible.

## Escalation

If an issue in the blueprint is not directly fixable (unknown root cause, connection account mismatch, obscure mapper behavior):
- Load `skills/failure-diagnostician/SKILL.md` — classify the issue against the taxonomy
- If it matches a known pattern: cite the code and apply the taxonomy fix
- If it's a new pattern: flag it and route to taxonomy-curator agent
