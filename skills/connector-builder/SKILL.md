---
name: connector-builder
description: Sets up and validates Make.com connections. Three modes — manage (check existing), setup-guide (step-by-step OAuth/API key instructions), credential-request (team-shared connections). Called during bootstrap gap analysis and pre-sprint checks.
---

# Skill: connector-builder

Manages Make.com connections — checking what exists, guiding setup of new ones,
and creating credential requests for team-shared connections.

Called by scenario-orchestrator during bootstrap gap analysis and by sprint-runner
as a prerequisite check before building each scenario.

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

## Three Modes

### Mode 1 — Manage (Check Existing)

**When called:** Bootstrap phase, pre-sprint prerequisite check

Steps:
1. `mcp__claude_ai_Make__connections_list` → get all connections
2. For each required service in the automation portfolio:
   - Find matching connection(s)
   - Check `status` field (valid/invalid/expired)
   - Flag any invalid or expired connections

Output:
```
CONNECTION STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ HubSpot            Connected (pierre@company.com)
✅ Gmail              Connected (pierre@company.com)
⚠️  Slack              Token expired — needs re-auth
❌ Stripe              Not connected — setup required
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

For expired tokens: provide re-auth instructions (Make.com UI steps).
For missing connections: switch to Setup Guide mode.

---

### Mode 2 — Setup Guide (Step-by-Step Instructions)

**When called:** A required service has no connection yet

Provide plain-language setup instructions per connection type:

#### OAuth2 Services (Gmail, Google Sheets, HubSpot, Slack, etc.)
```
To connect {service} to Make.com:

1. Open Make.com → go to Connections (left sidebar)
2. Click "Add a connection"
3. Search for "{service}" and select it
4. Click "Sign in with {service}"
5. Log in with your {service} account when prompted
6. Grant the permissions Make.com requests
7. Name your connection (e.g., "{service} — {your name}")
8. Click Save

Once done, come back here and I'll verify it's connected.
```

#### API Key Services (OpenAI, Stripe, Airtable, etc.)
```
To connect {service} to Make.com:

1. Open Make.com → go to Connections (left sidebar)
2. Click "Add a connection"
3. Search for "{service}" and select it
4. Go to your {service} account:
   {service-specific path to API key, e.g., "Settings → API → Create Key"}
5. Copy the API key
6. Paste it into the Make.com connection form
7. Name your connection (e.g., "{service} — Production")
8. Click Save and verify

Once done, come back here and I'll verify it's connected.
```

#### Webhook-Only Services (custom HTTP)
```
No persistent connection needed for {service}.
This automation will use a webhook URL that Make.com generates automatically.
I'll create that when we build the scenario.
```

---

### Mode 3 — Credential Request (Team-Shared Connections)

**When called:** User indicates a team member owns the credentials, or a shared team connection is needed

Steps:
1. Identify who owns the credentials (ask if unclear)
2. Check pending requests: `mcp__claude_ai_Make__credential-requests_list`
3. If no pending request exists for this service:
   - Present the credential request plan (Level 1 gate)
   - Create: `mcp__claude_ai_Make__credential-requests_create`
4. Surface to user:

```
CREDENTIAL REQUEST CREATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Service: {service}
Request ID: {id}
Status: Pending

{Team member / admin} will receive a notification to approve the connection.
Once approved, I'll automatically detect it and proceed with the build.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

**Blocking connections:** those required by at least one automation in the sprint queue.
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
