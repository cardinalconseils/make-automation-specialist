---
name: agent-safety
description: "Behavioral constraints for Make.com autonomous agents — what may and may not be done without explicit human confirmation during /factory and /make sessions"
allowed-tools: Read, Glob, Grep
---

# Agent Safety — Autonomous Operation Constraints

## Purpose

Define the boundary between actions an agent may take autonomously and actions
that require an explicit human confirmation step. These rules apply to ALL agents
in this plugin, especially `scenario-orchestrator` during `/factory` runs.

---

## NEVER Without Human Confirmation

These actions require the approval block (see CLAUDE.md `## Approval Gates`) and
an explicit "approve" reply before any MCP call is made:

| Action | Reason |
|--------|--------|
| `scenarios_activate` | Starts consuming operations and billing |
| `scenarios_delete` | Permanent — cannot be recovered |
| `hooks_delete` | Breaks all upstream triggers immediately |
| `data-stores_delete` | All records lost permanently |
| `data-store-records_delete` (bulk) | Mass data loss |
| Any production scenario modification | Risk of breaking live automation |
| Third-party API call that incurs cost | Credits consumed per call |
| Adding a new Make.com connection | Requires OAuth from user |

---

## MAY Do Autonomously (No Confirmation Needed)

| Action | Notes |
|--------|-------|
| `scenarios_list`, `scenarios_get` | Read-only, no side effects |
| `scenarios_create` in draft state | Not active, no operations consumed |
| `scenarios_update` on a draft | Safe — scenario not yet active |
| `validate_blueprint_schema` | Validation only |
| `app_documentation_get` | Documentation fetch only |
| Write to `.make/` directories | Local audit trail only |
| Read any `.make/` file | Memory and context reads |

---

## Graduated Trust During /factory

The orchestrator runs four phases. Trust escalates with each approval:

1. **Kickstart** — All reads are autonomous. No writes.
2. **Bootstrap** — Writes `.make/context/` files. Autonomous.
3. **System Design** — Writes `.make/plans/`. Shows plan. STOP for approval.
4. **Sprint** — Executes plan one step at a time. Each MCP write requires approval.

**Never batch approvals.** Each write MCP call gets its own confirmation.

---

## On Unexpected State

If the agent encounters unexpected state (scenario already exists, webhook URL changed,
connection expired), it must:

1. Stop immediately — do not attempt to work around it
2. Surface the discrepancy to the user in plain language
3. Propose options and wait for a decision

Never silently compensate for unexpected state.
