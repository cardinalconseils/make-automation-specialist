---
name: docs-researcher
description: Fetches exact Make.com module documentation before any blueprint is designed. Returns precise field names, required vs optional parameters, data types, and enumerated values. Eliminates improvisation and ensures first-shot accuracy.
---

# Make.com Docs Researcher

## Purpose

Never guess module parameters. Before writing a single module into a blueprint, look up the exact specification.

Improvising field names wastes tokens, causes validation failures, and requires multiple retries. One accurate lookup costs less than three failed attempts.

---

## When This Skill Is Required

Call this skill before:
- Designing any new scenario blueprint
- Adding a new module to an existing scenario
- Proposing a plan that references a specific Make.com app or module
- Writing any `scenarios_create` or `scenarios_update` payload

It is never optional. No exceptions.

---

## Lookup Sequence

Run these steps in order for each service the automation will use:

### Step 1 — Confirm the app exists

```
mcp__claude_ai_Make__apps_recommend
  input: { "search": "[service name]" }
  → returns: list of matching apps with their app slugs
```

Save the exact app slug. This is required for all subsequent calls.

### Step 2 — List all modules for the app

```
mcp__claude_ai_Make__app-modules_list
  input: { "appName": "[app slug from step 1]" }
  → returns: all modules with their module names, labels, and types
```

Identify the exact module that matches the business action needed.
Record the exact module name (e.g., `gmail:ActionSendEmail` not "Gmail send").

### Step 3 — Get the module specification

```
mcp__claude_ai_Make__app-module_get
  input: { "appName": "[app slug]", "moduleName": "[module name from step 2]" }
  → returns: full module spec including all parameters, types, and requirements
```

### Step 4 — Get full app documentation

```
mcp__claude_ai_Make__app_documentation_get
  input: { "appName": "[app slug]" }
  → returns: usage notes, authentication method, rate limits, known limitations
```

### Step 5 — Extract and record the exact spec

From the module specification, record:

| Field | Value |
|-------|-------|
| Module name (exact) | e.g., `gmail:ActionSendEmail` |
| Required fields | list with exact parameter names |
| Optional fields | list with exact parameter names |
| Field types | String, Integer, Boolean, Array, Select, etc. |
| Enumerated values | For Select fields — list all allowed values |
| Connection type | Which connection the module requires |
| Operation cost | Operations consumed per call |

---

## Multi-Module Scenarios

For scenarios with multiple services, run the full sequence above for every service before designing the blueprint.

Do not start designing until all modules are looked up.

---

## Blueprint Validation (After Design)

After designing the blueprint, validate it before proposing to the user:

```
mcp__claude_ai_Make__validate_blueprint_schema
  input: { blueprint JSON }
  → must return: valid

mcp__claude_ai_Make__validate_module_configuration
  input: { each module config }
  → must return: valid for each module

mcp__claude_ai_Make__validate_scheduling_schema  (if scheduled trigger)
mcp__claude_ai_Make__validate_hook_configuration (if webhook trigger)
mcp__claude_ai_Make__validate_epoch_configuration (if date/time fields used)
```

If any validation fails: fix the issue using the exact spec from Step 3. Do not guess a fix — re-read the spec.

---

## Output Format

After completing the lookup, produce a Module Spec Card for each module before using it in a blueprint:

```
MODULE SPEC: [Module label]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App:          [app slug]
Module:       [exact module name]
Type:         [trigger / action / search / instant trigger]
Connection:   [connection type required]
Cost:         [n operations per call]

REQUIRED FIELDS
  [field name]    [type]    [description or allowed values]
  ...

OPTIONAL FIELDS
  [field name]    [type]    [description or allowed values]
  ...

NOTES
  [any rate limits, known issues, or usage constraints from docs]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Show this card to the user when presenting the plan. It proves the plan is based on exact specs, not assumptions.

---

## Connection Verification

For each connection type identified in Step 3, verify it exists in the workspace:

```
mcp__claude_ai_Make__connections_list
  → filter for connections matching the required app
```

If the connection does not exist:
- Flag it in the plan as a prerequisite
- Do not attempt to create the scenario until the connection is confirmed
- Tell the user: "Before I can build this, you will need to connect [service] in Make.com. I'll walk you through that first."

---

## What to Do When a Module Is Not Found

If `app-modules_list` returns no matching module for the required action:

1. Search with a different term — the module may be named differently
2. Check if the action is covered by a generic module (e.g., "Search", "Watch", "Update")
3. If genuinely no native module exists: document it explicitly

```
NO NATIVE MODULE FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Service: [name]
Action needed: [what the user wants to do]
Lookup attempted: [what you searched for]
Result: No native module exists in Make.com for this action.

Options:
1. Use the HTTP module with manual auth setup (more fragile)
2. Use a different service that has a native module
3. Wait — Make.com adds new modules regularly

Recommendation: [your specific recommendation]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Never silently fall back to HTTP. Always surface the decision to the user.
