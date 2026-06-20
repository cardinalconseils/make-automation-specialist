# Automation Planner — Plan Template

Full template for AutomationPlan documents.
Referenced by `agents/automation-planner.md`.

---

## File Location

Write to: `.make/plans/{timestamp}-{slug}.md`

---

## Full Plan Template

```markdown
# AutomationPlan: {title}

**Created:** {timestamp}
**Status:** pending-approval
**Risk Level:** {Low / Medium / High}

## Business Requirement
{plain-language summary of what the user wants}

## Automation Overview
{2-3 sentence plain-language description of what the scenario will do}

## Trigger
**Type:** {Webhook / Schedule / Instant / Watch}
**Description:** {what causes this to run}
**Make.com Module:** {module name}
**Docs:** {link}

## Steps

### Step 1 — {Name}
**Module:** {Make.com module name}
**Docs:** {link}
**What it does:** {plain-language}
**Data in:** {input fields}
**Data out:** {output fields}
**Can fail?** {Yes / No}
**Error handler needed?** {Yes / No}

### Step 2 — ...

## Error Handling
**Strategy:** {auto-retry + Telegram alert / log only / halt + alert}
**Retry policy:** {max 3 attempts, 30-second backoff}
**Alert recipient:** {Telegram chat ID from env}
**Log location:** `.make/logs/`

## Cost Estimate

| Item | Monthly Estimate |
|------|-----------------|
| Make.com operations | {n} ops/run × {frequency} = {total}/month |
| Make.com cost | {tier-based estimate} |
| External API calls | {n calls × $rate} |
| Total estimated | ${total}/month |

**Current plan limit:** {from workspace.json if known}
**Operations after this:** {total + existing usage}/month

## Risk Assessment

**Level:** {Low / Medium / High}

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {risk} | {Low/Med/High} | {Low/Med/High} | {action} |

## Failure Pattern Risks
{Walk through PATTERN-001 to PATTERN-008. List any matches with mitigations.}
{If no matches: "No failure pattern risks detected."}

## Compliance Notes
{Any data privacy flags from compliance-scanner.}
{If none: "No compliance risks detected."}

## Mermaid Diagram
{diagram-generator skill output}

## Make.com Modules Reference
{List all modules used, each with doc link}

| Step | Module | Docs |
|------|--------|------|
| Trigger | {module} | {link} |
| Step 1 | {module} | {link} |

## Approval Required
This plan requires your approval before execution.
Type "approve" to proceed, or ask me to adjust anything.
```

