# Command: /blueprint-review

Review a Make.com blueprint JSON for issues before pushing to the API.

## Usage

```
/blueprint-review
/blueprint-review [paste blueprint JSON]
/blueprint-review [scenario ID]
```

## What It Does

1. Validates JSON structure
2. Checks all module ID references in flow/routes
3. Verifies connection IDs exist in account
4. Audits mapper expressions for syntax issues
5. Reviews error handler coverage
6. Checks router/filter logic
7. Returns: ✅ Passed / ⚠️ Warnings / ❌ Issues with fixes

## Examples

```
/blueprint-review
/blueprint-review 5347687
```

## Skills Loaded
- `blueprint-review`
- `formula-expert`
- `failure-diagnostician`
