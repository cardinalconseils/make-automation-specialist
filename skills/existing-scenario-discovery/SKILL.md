---
name: existing-scenario-discovery
description: Reverse-engineers existing Make.com scenarios into project context artifacts. Called by /kickstart when user selects "existing project" mode.
---

# Skill: existing-scenario-discovery

Reads live Make.com scenarios and produces the same artifacts as kickstart-intake,
from real blueprints instead of an interview.

## Permitted Operations

Read-only MCP calls only:
- `mcp__claude_ai_Make__scenarios_list`
- `mcp__claude_ai_Make__scenarios_get`
- `mcp__claude_ai_Make__extract_blueprint_components`
- Read / Write (files only)

BLOCKED: any create, update, activate, deactivate, delete, or run call.

## Step 1 — List Scenarios

Call `scenarios_list`. Display:

```
YOUR MAKE.COM SCENARIOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] {name} — {active/inactive} — last run {date}
[2] {name} — ...

Which scenario(s) should I map? Enter numbers (e.g. "1, 3") or "all".
```

If `scenarios_list` fails: tell the user to check the Make.com MCP connection. Do not proceed.

## Step 2 — Fetch & Parse Blueprints

For each selected scenario:
1. Call `scenarios_get` + `extract_blueprint_components`
2. Parse into plain-language automation object:
   - `trigger`: first module — service + event type
   - `action`: middle modules translated to business terms
   - `destination`: last module output target
   - `frequency`: schedule config or "webhook-triggered"
   - `status`: active / inactive

## Step 3 — Confirm Plain-Language Translation

Show each scenario translated, ask for corrections:

```
Here's what I found ({n} scenario(s)):

[1] {scenario name}
    Trigger: {plain-language}
    → Does: {plain-language steps}
    → Result: {destination}
    Status: {active/inactive} | Complexity: {Low/Medium/High}

Does this look right? Anything to correct before I build the project map?
```

Update descriptions based on user corrections before proceeding.

## Step 4 — Gap Interview

```
Now that I've mapped your existing automations —
is there anything you want to add, fix, or change?
(New automations to build? Things not working? Improvements?)
```

Collect additions using the same per-automation fields as kickstart-intake.
Mark existing scenarios `status: existing`, new ones `status: idea`.

## Step 5 — Return to Orchestrator

Return combined automation list to `/kickstart` Step 3 for artifact generation.
Use the same output contract as kickstart-intake.

## Hard Rules

- Read-only: never modify a scenario
- Always confirm plain-language translation before writing artifacts
- Mark existing vs. new automations clearly in all artifacts
