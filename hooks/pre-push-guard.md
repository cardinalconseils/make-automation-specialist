# Hook: pre-push-guard

**Event:** before.agent.respond
**Type:** Workflow gate — fires when a local API push is detected or planned

## Purpose

Enforce the plan-before-push requirement whenever the agent is about to execute a local blueprint push (direct API call via `curl -X PUT`). This ensures no blueprint reaches Make.com without a corresponding plan documenting what is changing and why.

## Trigger Conditions

Fire this hook when the agent's next action is any of:
- Constructing or executing a `curl -X PUT ... /api/v2/scenarios/{id}` command
- Calling `mcp__claude_ai_Make__scenarios_update` with blueprint data (covered separately by `pre-execute`)
- Responding to a user request to "push", "deploy", "send the blueprint", or "update the scenario"

Do NOT fire for:
- Read-only API calls (GET)
- MCP tool calls (handled by `pre-execute`)
- Blueprint review or validation only

## Action

### Check 1 — Plan file exists
Before constructing the push command, verify `.make/plans/` contains at least one `.md` file.

If no plan file exists:
```
PUSH BLOCKED — No plan on file

A blueprint push to scenario {id} requires a plan in .make/plans/ first.

What to do:
  1. Run /plan to create a plan for this change
  2. Review the plan
  3. Then push

This gate cannot be bypassed.
```

Stop. Do not construct the push command.

### Check 2 — Blueprint review passed this session
Before pushing, confirm that `blueprint-review` was run on this file in the current session.

If review was not run:
```
PUSH BLOCKED — Blueprint not reviewed

Run /blueprint-review on .make/scenarios/{id}.json before pushing.
```

Stop. Do not push.

### Check 3 — Single change set
Remind the agent: this push should contain exactly one logical change set.

If the plan or file contains multiple unrelated changes:
```
⚠️  Multiple change sets detected in this blueprint.
Split into separate pushes — one logical change per push — then confirm which to apply first.
```

## After Successful Pass

When all checks pass, allow the push and emit:
```
[pre-push-guard] ✅ Plan confirmed · Blueprint reviewed · Proceeding with push
```

## Rules
- ALWAYS run this hook before constructing any `curl -X PUT /api/v2/scenarios` command
- The "no plan" and "not reviewed" conditions are hard stops — no exceptions
- This hook does not prevent reading, reviewing, or planning — only unguarded pushes
