# Telnyx Expert — Phone Number Management

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## Search and Purchase Flow

```
1. mcp__telnyx__list_available_phone_numbers
     country_code: "CA"
     area_code: "514"
     features: ["sms", "voice"]

2. mcp__telnyx__initiate_phone_number_order
     phone_numbers: ["+15141234567"]
     connection_id: "your-connection-id"     ← assign at purchase time

3. mcp__telnyx__update_phone_number_messaging_settings
     phone_number_id: "..."
     messaging_profile_id: "..."             ← assign to messaging profile for SMS
```

**Always show estimated monthly cost before purchasing** (LEVEL 3 action — irreversible).

---

## Monthly Costs (approximate)

- Local DID (US/CA): ~$1–2/month
- Toll-free: ~$2–5/month + usage
- Short code: ~$500–1000/month (requires separate application)

---

## Toll-Free Numbers

- Format: 800, 833, 844, 855, 866, 877, 888 prefixes
- SMS: requires toll-free verification (separate from 10DLC); 3–5 business days
- Higher throughput than local numbers for A2P SMS

---

## Number Porting

- Porting moves your existing number from another carrier to Telnyx
- Takes 5–10 business days
- Must be initiated through Telnyx portal — no API for porting
- Inform user: calls/SMS will be interrupted during porting window

---

## Managing Numbers

```
mcp__telnyx__list_phone_numbers          — list all owned numbers
mcp__telnyx__get_phone_number            — get details for one number
mcp__telnyx__update_phone_number         — change connection/config (LEVEL 2)
mcp__telnyx__update_phone_number_messaging_settings  — change messaging profile
```

---

## Assigning a Number to a Connection

Numbers must be assigned to a connection for voice, and to a messaging profile for SMS.
A number can have both simultaneously:

```
mcp__telnyx__update_phone_number
  id: "phone-number-id"
  connection_id: "call-control-connection-id"   ← for voice

mcp__telnyx__update_phone_number_messaging_settings
  phone_number_id: "phone-number-id"
  messaging_profile_id: "messaging-profile-id"  ← for SMS
```
