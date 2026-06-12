---
description: Generate a Mermaid flowchart for a Make.com scenario. Read-only — never modifies anything.
argument-hint: Scenario name or ID
---

# /diagram — Generate a Scenario Flowchart

Read-only. No Make.com writes. No approval needed.

## Steps

1. If argument provided, use it to identify the scenario.
   Otherwise: `mcp__claude_ai_Make__scenarios_list` and ask user to pick.

2. `mcp__claude_ai_Make__scenarios_get` — fetch full blueprint

3. `mcp__claude_ai_Make__extract_blueprint_components` — parse module list and connections

4. Generate Mermaid flowchart (diagram-generator skill):
   - Trigger node (distinct shape — stadium or circle)
   - Each module as a process box
   - Data transformation steps
   - Conditional branches (filters, routers) as diamonds
   - Error paths as dashed lines
   - Final destination nodes
   - Plain-language labels — no Make.com internal IDs
   - Max 20 nodes; split into sub-diagrams if larger

5. Display diagram inline in conversation

6. Save to `.make/diagrams/{scenario-id}-{YYYY-MM-DD-HHmm}.md`

7. Ask: "Would you like a full written report too? Use /report."
