# Scenario Report Format

Used by scenario-reporter agent for `/report` output.

```markdown
# Scenario Report: {name}

**Generated:** {timestamp}
**Scenario ID:** {id}
**Status:** {active / inactive}
**Last run:** {datetime}
**Runs this month:** {count}
**Operations used this month:** {count}

## What This Scenario Does
{2-3 sentence plain-language description}

## Trigger
{plain-language trigger description}

## Steps
{numbered list in plain language — no jargon}

## Data Flow
{what goes in, what comes out, where it goes}

## Error Handling
{does it have error handling? what happens on failure?}

## Performance
| Metric | Value |
|--------|-------|
| Operations per run | {n} |
| Average run time | {ms} |
| Success rate (30d) | {%} |

## Diagram
{Mermaid flowchart}

## Observations
{Any notable patterns, potential issues, or recommendations}
Note: For a full audit with issue detection, use `/audit`.
```
