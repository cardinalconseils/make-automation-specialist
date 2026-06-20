# Scenario Orchestrator — Phase 2: System Design

## Phase 2 — SYSTEM DESIGN: Design All Scenarios

Goal: produce a validated design for every automation in the portfolio before touching
Make.com writes.

Announce: "Now I'll design all {n} automations. This is the thinking phase — nothing gets
built yet."

For each automation in the portfolio (in priority order):

### Per-Automation Design Steps (ALL deterministic)

```
Designing [{n} of {total}]: {title}
```

**Step 0 — AI Detection (before all other steps)**

Check if `automation.ai_required === true` in the session file.

If YES — run AI design track before standard module lookup:
  a. Call `ai-agent-designer` skill → produces AI Agent Blueprint
  b. Call `ai-docs-researcher` skill → fetches exact AI module specs
  c. Call `agent-pattern-library` skill → loads matching pattern + Mermaid diagram
  d. Proceed to step 1 with AI blueprint in hand

If NO — proceed directly to step 1.

**Standard Design Steps:**

1. `mcp__claude_ai_Make__apps_recommend` → find best apps for this use case
2. For each module: `mcp__claude_ai_Make__app-module_get` → get exact config schema
   - For AI modules: use specs from `ai-docs-researcher` (already fetched in Step 0)
   - For non-AI modules: run `docs-researcher` lookup as usual
3. Check `workspace.json` connections → flag missing ones
   - Flag AI provider connection separately (critical prerequisite)
4. Use plan-builder skill → construct full AutomationPlan
   - Pass AI Agent Blueprint as additional context if `ai_required: true`
5. Use `failure-patterns` skill → check plan against all 8 PATTERN-xxx codes; add
   mitigations for any matches
6. Use cost-estimator skill → estimate operations + cost
   - For AI automations: include AI token cost estimate alongside Make.com ops
7. Use compliance-scanner skill → flag any data privacy issues
8. Use diagram-generator skill → generate Mermaid flowchart
   - For AI automations: use pattern diagram from `agent-pattern-library` as base
9. `mcp__claude_ai_Make__validate_blueprint_schema` → pre-validate the blueprint
10. Use `blueprint-review` skill → 7-point pre-push checklist; fix all blockers before Sprint

Save each design to `.make/factory/{session_id}-design-{n}-{slug}.md`.

### Batch Design Review

After ALL automations are designed, present the complete portfolio design:

```
FULL DESIGN REVIEW — {n} AUTOMATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] {TITLE}                                [Risk: Low]
─────────────────────────────────────────────────
{2-sentence plain-language summary}
Steps: {n modules}
Cost: ~{n} ops/run × {freq} = ~{total}/month (~${cost}/month)
Connections needed: ✅ all connected / ⚠️ {service} needs setup
{compliance flag if any}

[Mermaid diagram]

────────────────────────
[2] {TITLE}                                [Risk: Medium]
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL PORTFOLIO ESTIMATE
Operations/month:  ~{total}
Monthly cost:      ~${total_cost}/month
Build order:       [1] → [2] → [3]

Make.com docs referenced:
• {module} → {url}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Review each design above.

To approve all and start building: type "build all"
To approve individually: type "approve [1]" for each
To change something: tell me what to adjust
```

Save full design document to `.make/factory/{session_id}-design.md`.

Do NOT proceed until approval is received. Wait.

Update `current-session.json` → `design_approved: true` after approval.
