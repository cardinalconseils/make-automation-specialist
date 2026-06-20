# Telnyx Expert — SIP Trunking and WebRTC

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## SIP Trunking Overview

SIP trunking connects a business phone system (PBX, Asterisk, FreePBX, 3CX) to
Telnyx for PSTN calls.

### Two Authentication Methods

**IP Authentication (recommended for static IPs):**
1. Create a SIP Connection with IP whitelist
2. No username/password — Telnyx accepts traffic from your IP
3. More secure, simpler to configure

**Credential Authentication:**
1. Create integration secret: `mcp__telnyx__create_integration_secret`
2. Use username/password in your PBX SIP trunk config
3. Use for dynamic IPs or cloud PBX systems

### SIP Endpoint Addresses

```
Outbound proxy:  sip.telnyx.com:5060  (UDP/TCP)
Secure:          sip.telnyx.com:5061  (TLS/SRTP)
```

### Inbound Routing

Assign a phone number to a SIP Connection:
```
mcp__telnyx__update_phone_number
  connection_id: "your-sip-connection-id"
```
Inbound calls ring your PBX via the SIP trunk.

### Caller ID (P-Preferred-Identity)

To present a custom caller ID on outbound calls:
Include `P-Preferred-Identity: <sip:+15141234567@sip.telnyx.com>` in your SIP INVITE.

### SIP Connection Tools

```
mcp__telnyx__get_connection            — read connection config
mcp__telnyx__update_connection         — modify settings (LEVEL 1)
mcp__telnyx__list_connections          — list all connections
mcp__telnyx__create_integration_secret — for credential auth (LEVEL 1)
```

---

## WebRTC

Telnyx WebRTC enables browser and mobile calling using the JavaScript SDK.

### SDK Installation

```bash
npm install @telnyx/webrtc
```

### Basic Click-to-Call Pattern

```javascript
import { TelnyxRTC } from "@telnyx/webrtc";

const client = new TelnyxRTC({
  login: "your-sip-username",
  password: "your-sip-password",
  host: "rtc.telnyx.com"
});

client.on("telnyx.ready", () => {
  const call = client.newCall({ destinationNumber: "+15140000000" });
});

client.connect();
```

### Setup Requirements

1. Create a **Credential Connection** in Telnyx portal
2. Create an **Integration Secret** via `mcp__telnyx__create_integration_secret`
3. Use credentials as SIP username/password in the WebRTC client
4. Assign a phone number to the Credential Connection for caller ID

### Make.com Integration

WebRTC calls generate the same Call Control webhook events as regular calls.
Configure the Credential Connection's webhook URL to point to your Make.com Custom Webhook.
Same `call.answered`, `call.hangup`, recording events apply.
