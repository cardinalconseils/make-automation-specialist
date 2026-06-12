---
description: Generate a plain-language written report for a Make.com scenario including performance stats, data flow, and observations. Read-only — never modifies anything.
argument-hint: Scenario name or ID
---

# /report — Generate a Scenario Report

Read-only. No Make.com writes. No approval needed.

## Steps

1. Identify scenario from argument or `mcp__claude_ai_Make__scenarios_list`

2. Fetch data (all deterministic):
   - `mcp__claude_ai_Make__scenarios_get` — blueprint and metadata
   - `mcp__claude_ai_Make__extract_blueprint_components` — module structure
   - `mcp__claude_ai_Make__executions_list` — recent run history (last 30 days)
   - `mcp__claude_ai_Make__executions_get-detail` on the last 3 runs — performance data

3. Generate report:

```
SCENARIO REPORT: {name}
Generated: {timestamp}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: {Active / Inactive}
Last run: {datetime}
Runs this month: {n}
Operations used this month: {n}

WHAT THIS SCENARIO DOES
{2-3 sentences in plain language}

TRIGGER
{plain-language trigger description — no jargon}

STEPS
1. {plain-language step}
2. {plain-language step}
   ...

DATA FLOW
In:  {what data enters the scenario}
Out: {what data leaves and where it goes}

ERROR HANDLING
{Does it have error handling? What happens on failure?
If missing: flag it — recommend /audit for a fix}

PERFORMANCE (last 30 days)
Operations per run:   {avg}
Average run time:     {ms}
Success rate:         {%}
Last error:           {datetime and plain-language description, or "None"}

DIAGRAM
{Mermaid flowchart}

OBSERVATIONS
{Notable patterns, potential issues, or recommendations.
For a full audit with fix proposals, use /audit.}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

4. Save to `.make/audits/{scenario-id}-report-{YYYY-MM-DD-HHmm}.md`

5. Display inline. Offer `/audit` if issues were observed.
