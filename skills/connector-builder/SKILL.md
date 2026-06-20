---
name: connector-builder
description: Sets up and validates Make.com connections. Three modes — manage (check existing), setup-guide (step-by-step OAuth/API key instructions), credential-request (team-shared connections). Called during bootstrap gap analysis and pre-sprint checks.
---

# Skill: connector-builder

Manages Make.com connections — checking what exists, guiding setup of new ones,
and creating credential requests for team-shared connections.

Called by scenario-orchestrator during bootstrap gap analysis and by sprint-runner
as a prerequisite check before building each scenario.

See [CONNECTOR-STEPS.md](./CONNECTOR-STEPS.md) for the three operating modes
and their step-by-step instructions (Manage, Setup Guide, Credential Request).

---

## Deterministic Classification

### Deterministic (call freely, no gate)
```
mcp__claude_ai_Make__connections_list              ← inventory all connections
mcp__claude_ai_Make__connections_get               ← inspect a connection
mcp__claude_ai_Make__connection-metadata_get       ← get connection type metadata
mcp__claude_ai_Make__credential-requests_list      ← list pending credential requests
mcp__claude_ai_Make__credential-requests_get       ← inspect a credential request
```

### Level 1 — Standard Write (gated by pre-execute hook)
```
mcp__claude_ai_Make__credential-requests_create                ← request team credentials
mcp__claude_ai_Make__credential-requests_create-by-credentials ← create with credentials
mcp__claude_ai_Make__credential-requests_extend-connection     ← extend existing connection
```

### Level 3 — PROHIBITED in this skill
```
mcp__claude_ai_Make__credential-requests_delete          ← never called here
mcp__claude_ai_Make__credential-requests_credential-delete ← never called here
```

---

## Gap Analysis Output (for Bootstrap Phase)

After checking all required connections against the automation portfolio, produce:

```json
{
  "connected": ["HubSpot", "Gmail"],
  "expired": ["Slack"],
  "missing": ["Stripe", "Airtable"],
  "webhook_only": ["Typeform"],
  "blocking": ["Stripe"],
  "setup_guides_provided": ["Stripe", "Airtable"],
  "credential_requests_created": []
}
```

**Blocking connections:** required by at least one automation in the sprint queue.
Surface these prominently — the sprint cannot proceed without them.

---

## Requirements Checklist Entry Format

For each connection, add to `.make/context/requirements.md`:

```markdown
## Connections Required

| Service | Status | Auth Type | Blocking? | Notes |
|---------|--------|-----------|-----------|-------|
| HubSpot | ✅ Connected | OAuth2 | No | pierre@company.com |
| Stripe | ❌ Missing | API Key | Yes | Needed for payment automation |
| Slack | ⚠️ Expired | OAuth2 | No | Re-auth needed before sprint |
```

---

## Output Contract

Returns to calling agent:
```json
{
  "status_by_service": {
    "HubSpot": "connected",
    "Stripe": "missing",
    "Slack": "expired"
  },
  "blocking_missing": ["Stripe"],
  "setup_guides_shown": ["Stripe"],
  "credential_requests_created": [],
  "ready_to_proceed": false
}
```
