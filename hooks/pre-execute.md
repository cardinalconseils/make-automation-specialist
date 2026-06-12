# Hook: pre-execute

**Event:** before.mcp.write
**Trigger:** Fires before any Make.com MCP call that modifies state

## Purpose

Enforce the approval gate. No write operation proceeds without user confirmation.

## Scope — What Triggers This Hook

Any Make.com MCP call with these operations:
- `create_scenario`
- `update_scenario`
- `delete_scenario`
- `activate_scenario`
- `deactivate_scenario`
- `run_scenario`
- `create_connection`
- `delete_connection`
- `update_module`

Does NOT trigger for:
- `get_scenario` (read)
- `list_scenarios` (read)
- `get_execution_history` (read)

## Approval Gate Protocol

### 1. Check if approval was given this session

If the calling agent already showed a plan and received approval for this specific action:
- Check session memory for approval marker
- If approval exists and is for this exact action → proceed
- If no approval or approval is for different action → show gate

### 2. Display Approval Gate

```
APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action: {plain-language description of what will happen}
Target: {scenario name}
Type: {create / modify / delete / activate / run}
Risk: {Low / Medium / High}

{If create or modify: show summary of changes}
{If delete: show what will be lost}
{If run: show estimated operations this run}

Type "approve" to proceed, or ask me to change anything.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 3. Wait for User Response

Valid approval responses:
- "approve", "yes", "go ahead", "do it", "confirmed", "ok", "proceed"

If user says anything else: treat as a question or modification request, not approval.
Ask for clarification. Do not execute.

### 4. Mark Approval in Session

After receiving approval, note in session context:
- `approved_action`: {action type}
- `approved_target`: {scenario name/id}
- `approved_at`: {timestamp}

### 5. Hard-Stop for Delete Operations

For any delete operation, use this stronger gate regardless of prior approval:

```
DESTRUCTIVE ACTION — CANNOT BE UNDONE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You are about to permanently delete:

  Scenario: {name}
  Created: {date}
  Last run: {date}
  Modules: {count}

This cannot be undone. Make.com does not have a recycle bin.

Type exactly: DELETE {scenario name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Only proceed if user types the exact confirmation phrase.

## Logging

Log every approval (or refusal) to `.make/logs/approvals.md`:

```markdown
## {timestamp}
Action: {action}
Target: {target}
Status: {approved | refused | cancelled}
Agent: {agent-id}
```
