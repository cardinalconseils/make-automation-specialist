---
name: diagram-generator
description: Generates Mermaid flowcharts from parsed scenario data (scenario-reader output). Called by scenario-reporter and automation-planner. Saves diagrams to .make/diagrams/.
---

# Skill: diagram-generator

Generates Mermaid flowcharts from parsed scenario data (scenario-reader output).
Called by scenario-reporter and automation-planner.

## Input

Structured scenario representation from scenario-reader skill.

## Output

Valid Mermaid flowchart syntax. Save to `.make/diagrams/{scenario-id}-{timestamp}.md`.

See [mermaid-template.md](mermaid-template.md) for the full Mermaid template and node naming rules.

## Complexity Limit

If scenario has > 20 modules:
- Generate a high-level diagram (main flow only, collapse sub-flows)
- Generate separate detailed diagrams per branch
- Label files: `{id}-overview.md`, `{id}-branch-1.md`, etc.

## Plain Language Notes

After the diagram, add a plain-language key:
```
## What This Diagram Shows

This scenario starts when [trigger description]. It then [step 1], [step 2],
and finally [destination]. If anything fails, [error handling description].
```

## File Format

Save as:
```markdown
# Scenario Diagram: {scenario name}
Generated: {timestamp}
Scenario ID: {id}

## Flow Diagram

```mermaid
{diagram}
```

## What This Diagram Shows
{plain-language description}
```
