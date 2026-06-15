# Command: /diagnose

Dispatch the `failure-diagnostician` agent to diagnose a Make.com scenario failure.

## Usage

```
/diagnose
/diagnose [error description]
/diagnose [scenario ID]
```

## What It Does

1. Loads the failure taxonomy
2. Asks for error details if not provided
3. Classifies the failure against taxonomy
4. States expected vs actual behavior
5. Prescribes the specific fix with explanation
6. Documents new patterns if discovered

## Examples

```
/diagnose
/diagnose my Google Sheets module is failing with 403
/diagnose scenario 5347687 stopped working
/diagnose isinvalid: true after blueprint push
/diagnose webhook not triggering
```

## Agent Dispatched
`failure-diagnostician`

## Skills Loaded
- `failure-diagnostician`
- `error-handler`
- `failure-patterns`
