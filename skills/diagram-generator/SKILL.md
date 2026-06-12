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

## Mermaid Template

```mermaid
flowchart TD
    %% Trigger
    T(["{trigger type}: {trigger name}"])

    %% Modules — use process shape for normal, decision for routers/filters
    M1["{module 1 name}"]
    M2["{module 2 name}"]
    M3{"{router/filter name}"}
    
    %% Error paths — dashed style
    E1[/"Error: {description}"/]
    E2[/"Alert: Telegram"/]

    %% Destination nodes
    D1(("{destination: e.g. Google Sheets}"))
    D2(("{destination: e.g. Email sent}"))

    %% Connections
    T --> M1
    M1 --> M2
    M2 --> M3
    M3 -->|"Yes"| D1
    M3 -->|"No"| D2
    
    %% Error paths (dashed)
    M1 -. "on error" .-> E1
    E1 --> E2

    %% Styling
    classDef trigger fill:#e8f4fd,stroke:#2196F3,stroke-width:2px
    classDef process fill:#f9f9f9,stroke:#666,stroke-width:1px
    classDef decision fill:#fff8e1,stroke:#FFC107,stroke-width:1px
    classDef error fill:#ffebee,stroke:#f44336,stroke-width:1px,stroke-dasharray:5 5
    classDef destination fill:#e8f5e9,stroke:#4CAF50,stroke-width:2px

    class T trigger
    class M1,M2 process
    class M3 decision
    class E1,E2 error
    class D1,D2 destination
```

## Node Naming Rules

- Use plain-language names, not Make.com internal module names
- "Google Sheets: Create Row" → "Save to Google Sheets"
- "HTTP: Make a Request" → "Call {API name} API"
- "Telegram Bot: Send Message" → "Send Telegram Alert"
- "Webhooks: Custom Webhook" → "Receive Form Submission"
- "Flow Control: Router" → "Route by {condition}"
- "Flow Control: Iterator" → "For each {item}"

## Shape Reference

| Shape | Use case | Mermaid syntax |
|-------|----------|----------------|
| Stadium `([text])` | Trigger node | `T([...])` |
| Rectangle `[text]` | Process / module | `M1[...]` |
| Diamond `{text}` | Router / filter / decision | `M3{...}` |
| Parallelogram `/text/` | Error / exception node | `E1[/".../"]` |
| Circle `((text))` | End destination | `D1((...))`  |

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
