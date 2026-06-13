# Automation Discipline Rules

Three rules for every automation design and change.

---

## 1. Simplicity First

Every automation must be as simple as possible while solving the actual problem.

- A two-module flow beats a ten-module flow if both solve the need
- No error-handling branches for scenarios that haven't failed in production
- No data stores for data that only flows through and is never read back
- One scenario per business process — no "do everything" mega-scenarios

**Test:** Can a non-technical user understand this scenario by reading the module names left-to-right?

---

## 2. Minimal Impact

Change only what the task requires.

- Do not restructure unrelated modules when fixing one step
- Do not add new connections when an existing one works
- Do not rename working modules to "improve clarity" unless asked
- If a scenario must be opened to fix one module, only change that module

**Test:** Every MCP write call must map to a stated task requirement. No silent improvements.

---

## 3. Root Cause Only — No Band-Aids

Find the actual failure point. Fix that.

- A filter that suppresses bad data is not a fix — find why the data is bad
- A retry module that masks a timing issue is not a fix — find the timing problem
- An error handler that swallows failures without alerting is not a fix — it's hidden debt
- If the root cause is upstream (a third-party API, a form, a human process) — say so

**Test:** Can you explain in one sentence WHY the fix prevents the failure, not just WHAT it does?

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll add the retry while I'm in here" | Unrequested changes break scenarios in unexpected ways. |
| "The filter is just a safeguard" | If data passes the filter unexpectedly, you've hidden the real bug. |
| "This cleaner structure will help later" | Ship the fix. Refactor only when asked. |
| "Adding a sleep module will fix the timing" | It works until it doesn't. Find the race condition. |
