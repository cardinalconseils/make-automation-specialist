# AI Agent Builder — Intake and Pattern Selection

Reference file for `agents/ai-agent-builder.md`.

## Phase 1 — Research (Deterministic)

Announce: "Now I'm looking up the exact specs for the AI modules we'll use..."

Run in order — no approval needed, all reads:

1. **Workspace check:**
   - `mcp__claude_ai_Make__connections_list` — check if AI provider connected
   - `mcp__claude_ai_Make__scenarios_list` — check for similar existing scenarios

2. **AI module lookup (via `ai-docs-researcher` skill):**
   - Get current model enum, required fields, JSON mode support
   - Verify connection exists or flag as prerequisite

3. **Tool module lookup (via `docs-researcher` skill for each tool):**
   - Get exact module specs for each (CRM, email, search, etc.)

4. **Pattern load (via `agent-pattern-library` skill):**
   - Load pattern matching the blueprint's task type
   - Get Mermaid diagram and module sequence

Surface findings:
```
RESEARCH COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AI module:     {provider} — {exact module name} ✅ / ⚠️ needs connection
Pattern:       {pattern name}
Tools ready:   {list} ✅
Tools missing: {list} ⚠️
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Phase 2a — Build the AI Agent Blueprint

Combine outputs from:
- `ai-agent-designer` (model, tools, memory, prompt)
- `ai-docs-researcher` (exact module specs)
- `agent-pattern-library` (pattern diagram and module sequence)
- `plan-builder` (full AutomationPlan with cost estimate)
- `compliance-scanner` (if personal/payment/health data detected)

## Phase 2b — Generate / Update Project Artifacts

**If `.make/context/context.md` does NOT exist:** create it.
**If `.make/context/prd.md` does NOT exist:** create it.
**Always:** append to `.make/context/ai-agents.md` (create if new).

See `agents/ai-agent-builder-artifact.md` for the full ai-agents.md entry format.

## Phase 2c — Present the Full Plan for Approval

```
AI AGENT DESIGN: {title}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What it does: {plain-language 2-sentence summary}
Pattern:      {pattern name}
Model:        {model name} — {why this model}

HOW IT WORKS
{Mermaid diagram from agent-pattern-library}

THE AI'S JOB
System: "{system prompt}"
It receives: {what triggers it and what data arrives}
It outputs:  {format and fields}

TOOLS AVAILABLE TO THE AI
  {tool name} → {Make.com module} → {when triggered}

MEMORY
  {memory strategy and implementation}

CONNECTIONS NEEDED
  ✅ Already connected: {list}
  ⚠️  Needs setup: {list with plain-language instructions}

COST ESTIMATE
  Per run:    ~{n} Make.com operations
  Per month:  ~{n} operations (~${n}/month on your plan)
  AI tokens:  ~${n}/month
  Total:      ~${n}/month

RISK
  Level: {Low / Medium / High}
  Notes: {what could go wrong — in plain language}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type "build" to proceed, or ask me to adjust anything.
```

Save plan to: `.make/plans/{YYYY-MM-DD-HHmm}-ai-agent-{slug}.md`

**DO NOT PROCEED until user types "build" or explicit approval.** Wait.
