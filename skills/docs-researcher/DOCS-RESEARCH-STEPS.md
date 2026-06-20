# Make.com Docs Research Steps

## Lookup Sequence

Run in order for each service the automation will use.

### Step 1 — Confirm the app exists
```
mcp__claude_ai_Make__apps_recommend { "search": "[service name]" }
```
Save the exact app slug — required for all subsequent calls.

### Step 2 — List all modules
```
mcp__claude_ai_Make__app-modules_list { "appName": "[app slug]" }
```
Record the exact module name (e.g., `gmail:ActionSendEmail` not "Gmail send").

### Step 3 — Get the module specification
```
mcp__claude_ai_Make__app-module_get { "appName": "[slug]", "moduleName": "[name]" }
```

### Step 4 — Get full app documentation
```
mcp__claude_ai_Make__app_documentation_get { "appName": "[app slug]" }
```
Extract: auth method, rate limits, known limitations.

### Step 5 — Extract and record the exact spec

Record: module name (exact), required fields, optional fields, field types,
enumerated values for Select fields, connection type, operation cost.

---

## Multi-Module Scenarios

Run the full sequence for every service before designing the blueprint.
Do not start designing until all modules are looked up.

---

## Blueprint Validation (After Design)

```
mcp__claude_ai_Make__validate_blueprint_schema      (always)
mcp__claude_ai_Make__validate_module_configuration  (each module)
mcp__claude_ai_Make__validate_scheduling_schema     (if scheduled trigger)
mcp__claude_ai_Make__validate_hook_configuration    (if webhook trigger)
mcp__claude_ai_Make__validate_epoch_configuration   (if date/time fields)
```

If validation fails: fix using the exact spec from Step 3. Do not guess.

---

## Output Format — Module Spec Card

```
MODULE SPEC: [Module label]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App:        [app slug]
Module:     [exact module name]
Type:       [trigger / action / search / instant trigger]
Connection: [connection type required]
Cost:       [n operations per call]

REQUIRED FIELDS
  [field name]    [type]    [description or allowed values]

OPTIONAL FIELDS
  [field name]    [type]    [description or allowed values]

NOTES
  [rate limits, known issues, or usage constraints]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## When a Module Is Not Found

1. Search with a different term — module may be named differently
2. Check if a generic module covers the action ("Search", "Watch", "Update")
3. If no native module exists:

```
NO NATIVE MODULE FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Service: [name]
Action needed: [what the user wants]
Result: No native module exists in Make.com for this action.
Options: 1. HTTP module (more fragile)  2. Different service  3. Wait
Recommendation: [specific recommendation]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Never silently fall back to HTTP. Always surface the decision to the user.
