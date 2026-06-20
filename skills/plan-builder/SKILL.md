---
name: plan-builder
description: Constructs a structured AutomationPlan from a business requirement. Maps requirements to Make.com modules, designs error handling, and runs the guardrail checklist. Called by automation-planner and automation-specialist agents.
---

# Skill: plan-builder

Constructs a structured AutomationPlan from a business requirement.
Called by automation-planner agent and automation-specialist agent.

## Input Contract

Receive:
- `business_requirement` — structured summary from interview
- `available_mcps` — list of MCPs available in current session
- `workspace_context` — from `.make/workspace.json`
- `budget_constraint` (optional) — max operations/month or cost/month

## Process

### 1. Map Business Requirement to Make.com Architecture

Identify:
- **Trigger type:** Is this event-based (webhook/instant) or time-based (schedule)?
- **Data sources:** What APIs/services are involved?
- **Transformations:** What data manipulation is needed?
- **Actions:** What happens at the end (send, write, notify)?
- **Volume:** Estimated runs per day/month

### 2. Detect AI Requirements

See [ai-module-selection.md](ai-module-selection.md) for the full AI detection and module selection rules.

### 3. Select Make.com Modules (Non-AI Steps)

See [module-selection.md](module-selection.md) for the full module selection hierarchy and reference table.

### 4. Design Error Handling

For every step that can fail (network, API, file operations):
- Add error handler route
- Define retry logic (default: 3 attempts, exponential backoff)
- Define escalation: log + Telegram alert if retries exhausted
- Define data: what gets logged on failure

### 5. Build Plan Document

Use the AutomationPlan template from automation-planner.md.

### 6. Return Plan

Return the complete plan markdown and the plan file path to the calling agent.

## Guardrail Checklist

Before finalizing plan, confirm:
- [ ] Error handler on every network/API module
- [ ] Retry policy defined
- [ ] Telegram alert path for unresolvable failures
- [ ] Filter before any expensive downstream operations
- [ ] No hardcoded credentials — all via Make.com connection manager
- [ ] Operation count estimate included
- [ ] Cost estimate included
- [ ] Risk level assigned
