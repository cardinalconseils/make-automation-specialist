# Destructive Operations Rules

## Mandatory Warning Format

Before suggesting OR running any destructive operation, output this block:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ DESTRUCTIVE ACTION — REVIEW BEFORE PROCEEDING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:     [what will happen, in plain English]
Target:     [exact scenario, webhook, connection, or data store]
Reversible: YES / NO / MAYBE (with condition)
You lose:   [what is gone if this runs and is wrong]
Safer alt:  [a safer option, or "none"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

This block must appear BEFORE the MCP call — never silently run a destructive action.

## What Counts as Destructive (Make.com)

- `scenarios_delete` — deletes a scenario permanently
- `scenarios_activate` — activates a draft; starts consuming operations
- `scenarios_deactivate` — stops a live scenario
- `hooks_delete` — deletes a webhook; breaks any upstream trigger
- `data-stores_delete` — deletes a data store and all records
- `data-store-records_delete` — deletes a data record
- `connections_delete` (if available) — removes an authorized connection
- Any `*_delete`, `*_deactivate`, or `*_replace` MCP call

## What Counts as Destructive (File system)

- `rm`, `rm -rf`, overwriting `.make/memory/` files

## Required Behavior

- Never batch multiple destructive operations silently — each gets its own block
- Never use phrases like "I'll just clean this up" without the block first
- For irreversible actions: state "This cannot be undone" explicitly
- Always suggest a safer alternative when one exists:
  - Scenario delete → deactivate first, then archive
  - Data store delete → export records first
  - Webhook delete → update the source to stop sending instead

## On Confirmation

When the user says "yes, proceed":
- Confirm: "Running: [exact MCP call]"
- Run only the approved operation — do not expand scope
- After completion: "Deleted: [specific target]"
