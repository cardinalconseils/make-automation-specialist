---
description: Reverse-engineer existing Make.com scenarios into project context artifacts. Maps live blueprints into plain-language automation descriptions and produces the same context files as /kickstart.
---

# /existing-scenarios — Map Existing Scenarios

Discover and document what's already running in your Make.com workspace before
building anything new. Read-only — no changes to any scenario.

## Usage

```
/existing-scenarios
/existing-scenarios [scenario name or id]
```

## Dispatch

Route to the `existing-scenario-discovery` skill.

Pass context:
- Specific scenario name/ID if provided by the user
- Otherwise let the skill list all scenarios and prompt for selection

## When to use

- Starting a new project session and want to map what already exists
- Before running `/kickstart` on an established workspace
- Auditing what scenarios are active without running `/audit`

## Output

Writes to `.make/context/`:
- `context.md` — automation inventory in plain language
- `erd.md` — data flow diagram of discovered scenarios

Displays a plain-language summary of every mapped scenario.
