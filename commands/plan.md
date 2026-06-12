---
description: Generate a detailed automation plan with cost estimate, risk assessment, and Mermaid diagram — without executing anything. Use this to think before you build.
argument-hint: Describe what you want to automate
---

# /plan — Generate an Automation Plan (No Execution)

You are in planning-only mode. You will produce a complete AutomationPlan.
**You will not create, update, or activate anything in Make.com during this command.**

## Phase 0 — System Design First (Deterministic reads)

1. `mcp__claude_ai_Make__users_me` — confirm context
2. `mcp__claude_ai_Make__teams_list` — get team ID
3. `mcp__claude_ai_Make__scenarios_list` — check for existing similar automations (avoid duplication)
4. `mcp__claude_ai_Make__connections_list` — what's already connected
5. `mcp__claude_ai_Make__data-structures_list` — existing schemas

## Phase 1 — Understand the Requirement

If an argument was provided, use it. Otherwise ask the user to describe the automation in plain language.

Collect: trigger, action, destination, frequency. Reflect back before planning.

## Phase 2 — Research & Design (Deterministic)

1. `mcp__claude_ai_Make__apps_recommend` — find best apps for this use case
2. `mcp__claude_ai_Make__app-module_get` for each module — get exact schemas
3. `mcp__claude_ai_Make__validate_blueprint_schema` — pre-validate the plan
4. Generate cost estimate (cost-estimator skill)
5. Generate Mermaid diagram (diagram-generator skill)
6. Identify compliance considerations (compliance-scanner skill)

## Phase 3 — Produce Plan

Save to `.make/plans/{YYYY-MM-DD-HHmm}-{slug}.md` and display:

```
AUTOMATION PLAN: {title}
Status: draft — not yet built
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT IT DOES
{2-3 sentence plain-language description}

TRIGGER
Type: {Webhook / Schedule / Watch}
Description: {what causes this to fire}
Make.com module: {name} — {doc link}

STEPS
1. {Module name}
   What: {plain-language}
   Input: {fields}
   Output: {fields}
   Can fail: Yes → error handler included
   
2. {Module name}
   ...

CONNECTIONS NEEDED
✅ {service} — already connected (connection ID: {id})
⚠️  {service} — NOT yet connected. Setup needed before activation.

ERROR HANDLING
• Retry policy: 3 attempts, 30-second backoff
• On unresolvable error: log + Telegram alert
• Log location: .make/logs/

DATA FLOW
{plain-language: what goes in, what transforms, what comes out}

COST ESTIMATE
Operations per run:    ~{n}
Monthly runs:          ~{n}
Total operations/mo:   ~{n}
Estimated cost:        ~${amount}/month
Current plan usage:    {n}/{limit} ops/month

RISK LEVEL: {Low / Medium / High}
{risk table if Medium or High}

COMPLIANCE
{any flags — GDPR, Quebec Law 25, etc.}
This is not legal advice. Review with your legal team.

DIAGRAM
{Mermaid flowchart}

MODULE DOCS
{list of Make.com documentation links}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
To build this automation, type: /make {brief description}
To adjust anything, just tell me what to change.
```
