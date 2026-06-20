# Connector Builder — Build Steps

## Mode 1 — Manage (Check Existing)

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

## Mode 2 — Setup Guide (Step-by-Step Instructions)

**When called:** A required service has no connection yet

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

## Mode 3 — Credential Request (Team-Shared Connections)

**When called:** User indicates a team member owns the credentials

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
