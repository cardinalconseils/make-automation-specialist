# Intake: Artifacts 3–4

Part of `kickstart-intake`. See `INTAKE-ARTIFACTS.md` for execution order.
For Artifacts 5–6 and the generation summary, see `INTAKE-ARTIFACTS-3.md`.

---

## Artifact 3 — erd.md

Two sections in one file: the **integration map** (how data moves) below, then the
**entity model** (what data exists) — the `erDiagram` + Entity Storage table specified in
`INTAKE-ARTIFACTS-PROCESS-MAP.md`. Both are required; a file with only the flowchart is
not an ERD.

````markdown
# Data Model & Flow
**Generated:** {date}

## Integration Map

```mermaid
flowchart LR
  subgraph Sources
    S1["{trigger service 1}"]
    S2["{trigger service 2}"]
  end
  subgraph Make.com
    M1["{automation title 1}"]
    M2["{automation title 2}"]
  end
  subgraph Destinations
    D1["{destination service 1}"]
    D2["{destination service 2}"]
  end
  S1 -->|"{data type}"| M1
  S2 -->|"{data type}"| M2
  M1 -->|"{data type}"| D1
  M2 -->|"{data type}"| D2
  M1 -->|"{data type}"| D2
```

## Data Objects
| Object | Source | Used By | Destination |
|--------|--------|---------|-------------|
| {data type} | {service} | {automation} | {service} |
````

Then append the **Entity Model** and **Entity Storage** sections from
`INTAKE-ARTIFACTS-PROCESS-MAP.md`.

---

## Artifact 4 — system-design.md

```markdown
# System Design
**Generated:** {date}

## Architecture Overview
{Plain-language description of how the automations work together}

## Trigger Inventory
| Automation | Trigger Type | Source | Schedule / Event |
|------------|-------------|--------|-----------------|
| {title} | Webhook / Poll / Schedule | {service} | {detail} |

## Dependencies
{List inter-scenario dependencies — e.g., auto-001 feeds data to auto-003}

## Error Propagation
{How failures in one automation affect others}
```
