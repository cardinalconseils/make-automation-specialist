# Telnyx Expert — Dynamic API Access and CLI

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Dynamic API Access Pattern

For any Telnyx capability not covered by named MCP tools:

```
Step 1: mcp__claude_ai_Telnyx__list_api_endpoints
  → Review available endpoints by category

Step 2: mcp__claude_ai_Telnyx__get_api_endpoint_schema
  endpoint: "/v2/phone_numbers/{id}/actions/enable_emergency_calling"
  → Understand required parameters

Step 3: mcp__claude_ai_Telnyx__invoke_api_endpoint
  method: "POST"
  path: "/v2/phone_numbers/123/actions/enable_emergency_calling"
  body: { ... }
```

Use this pattern for:
- Emergency calling setup
- Number porting status checks
- Fax configuration
- Sub-accounts and billing
- Any endpoint added to Telnyx API after this skill was written

---

## Telnyx CLI — Local Development

The Telnyx CLI enables local testing without a public server.

### Installation

```bash
# macOS
brew tap telnyx/telnyx && brew install telnyx-cli

# Or npm
npm install -g @telnyx/cli
```

### Authentication

```bash
telnyx login
# Enter your API key when prompted
```

### Local Webhook Tunnel

Forward Telnyx webhooks to your local machine:
```bash
telnyx webhook listen --port 3000
```
This gives you a public URL like `https://abc123.webhooks.telnyx.com`.
Use that URL in your Call Control Application or Messaging Profile webhook config.

### Common CLI Commands

```bash
# Test outbound SMS
telnyx messages send --from +15141234567 --to +15140000000 --text "Hello from CLI"

# List phone numbers
telnyx phone-numbers list

# Get phone number details
telnyx phone-numbers get +15141234567

# List messaging profiles
telnyx messaging-profiles list

# View recent calls
telnyx calls list

# Run API call
telnyx api get /v2/phone_numbers
```

### Testing Workflow

1. `telnyx webhook listen --port 3000` — start local tunnel
2. Update webhook URL in Call Control App or Messaging Profile to tunnel URL
3. Make a test call or send a test SMS to your Telnyx number
4. Watch webhook events arrive in your local server logs
5. Iterate on your Make.com scenario or code without deploying to a server
