# Rule: Make Failure Taxonomy Protocol

## Applies To
All agents and skills in the make-automation-specialist plugin when handling errors, failures, or unexpected Make.com behavior.

## Required Behavior

### Before Suggesting Any Fix
1. Load `taxonomy/make-failure-taxonomy.md`
2. Identify the matching taxonomy code
3. If no match: ask clarifying questions — do NOT guess

### When Responding to a Failure
Always include:
- **Classification code** (e.g., `HTTP-429`)
- **Expected vs Actual** statement
- **Root cause** from taxonomy
- **Fix** with numbered steps
- **Why it works** explanation

### When Discovering a New Pattern
1. Flag it: "This pattern is not yet in the taxonomy."
2. Gather: symptom, root cause, fix, any Make-specific nuance
3. Confirm with user
4. Add via taxonomy-updater skill or taxonomy-curator agent

## Prohibited

- Suggesting a fix without first classifying the failure
- Guessing on Make behavior without taxonomy backing
- Skipping the taxonomy load for any error-related response
- Generic debugging advice ("try refreshing", "check your connection")

## Error Handler Rule

Every diagnosis must end with an error handler recommendation if:
- The failing module had no error handler
- The fix involves a retryable error (429, 5xx)
- The scenario is processing critical data

Reference `skills/error-handler/SKILL.md` for directive selection.
