# Hook: post-execute

**Event:** after.mcp.call
**Trigger:** Fires after any Make.com MCP call completes (success or failure)

## Purpose

Write execution log. Trigger Telegram alert if failure. Update workspace state.

## On Success

1. Call execution-logger skill → write log to `.make/logs/`
2. Update `operations_used_this_month` in `workspace.json`
3. Check operation usage threshold:
   - > 80% → add warning to next user-facing message
   - > 95% → call alert-dispatcher skill immediately
4. Report outcome to user in plain language (2-3 sentences max)

## On Failure

1. Capture error details (MCP response, error code, message)
2. Attempt auto-recovery:
   - Wait 10 seconds → retry once
   - If retry succeeds → log as "recovered" → continue with success flow
   - If retry fails → proceed to step 3
3. Call execution-logger skill → write error log to `.make/logs/`
4. Call alert-dispatcher skill → send Telegram alert
5. Surface to user:

```
Something went wrong with [plain-language description of what failed].

Error: [plain-language translation of error — NOT raw API message]

I've sent you a Telegram alert and logged the details.

What would you like to do?
- Try again
- Skip this step and continue
- Stop here and investigate
```

## Partial Success

If a multi-step execution partially completed before failure:
1. Log completed steps and failed step
2. Note which Make.com changes were made (for manual rollback if needed)
3. Tell user exactly what was and was not completed:

```
Partially completed:
  Done: Created the webhook trigger module
  Done: Added the Google Sheets lookup
  Failed: Could not connect the email notification step

The scenario was created but is NOT active. You can:
- Fix the email step and I'll activate it
- Activate it without the email step for now
- Start over
```

## Log Entry

Always write log regardless of outcome. Never skip. See execution-logger skill.
