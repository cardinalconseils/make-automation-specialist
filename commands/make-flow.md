# /make — Full Conversation and Build Flow

Reference file for `commands/make.md`.

## Phase 2 — Design (Deterministic Tools Only)

Once the requirement is confirmed:

1. Use `mcp__claude_ai_Make__apps_recommend` to identify the best Make.com apps
2. Check `connections_list` — are the needed connections already available? If not, flag this.
3. Use `mcp__claude_ai_Make__app-module_get` for each module — verify exact config schema
4. Design the scenario flow (modules, data mapping, error handlers)
5. Use `mcp__claude_ai_Make__validate_blueprint_schema` to pre-validate the planned blueprint
6. Use `mcp__claude_ai_Make__validate_module_configuration` for each module
7. Generate cost estimate (see cost-estimator skill)
8. Generate Mermaid diagram (see diagram-generator skill)

## Phase 3 — Present Plan (Approval Gate)

Show the full plan. Do not execute anything until the user approves.

```
AUTOMATION PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name: {suggested scenario name}
What it does: {2 sentences in plain language}

STEPS
1. {module name} — {plain-language description}
2. {module name} — {plain-language description}
   ...

CONNECTIONS NEEDED
✅ {service} — already connected
⚠️  {service} — not yet connected, setup needed before activation

ERROR HANDLING
• Auto-retry {n} times on failure
• Log errors to .make/logs/
• Telegram alert if unresolvable

COST ESTIMATE
• Operations per run: ~{n}
• At {frequency}: ~{n}/month
• Estimated cost: ~${amount}/month

RISK LEVEL: {Low / Medium / High}
{risk notes if Medium or High}

[Mermaid diagram]

Make.com docs for modules used:
• {module} → {url}
• {module} → {url}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type "approve" to build this, or tell me what to change.
```

Save plan to `.make/plans/{YYYY-MM-DD-HHmm}-{slug}.md`.

## Phase 4 — Execute (After Approval Only)

After receiving "approve" or clear equivalent:

1. Narrate each step before doing it: "Creating the webhook trigger now..."
2. If connections are missing, guide setup first before scenario creation
3. Create scenario via `mcp__claude_ai_Make__scenarios_create`
4. Activate via `mcp__claude_ai_Make__scenarios_activate`
5. On error: retry once, then alert via alert-dispatcher skill if still failing
6. Write execution log to `.make/logs/` (see execution-logger skill)

## Phase 5 — Confirm and Hand Off

After successful build:
```
✅ Your automation is live!

Scenario: {name}
Status: Active in Make.com
How to test it: {plain-language test instructions}

What happens next: {what the user will experience when it triggers}

Your audit trail is saved at: .make/logs/{filename}
```

Offer: "Would you like a diagram saved, or shall we run a test execution?"
