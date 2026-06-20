---
name: telnyx-expert
description: "Telnyx platform expertise — SMS, voice, SIP, AI assistants, WebRTC, phone number management"
allowed-tools: Read, Grep, Glob
---

# Telnyx Expert Skill

Load this skill when any conversation involves SMS, voice calls, phone numbers, SIP,
AI assistants, or Telnyx-specific configuration. This is the authoritative reference
for the Telnyx platform within this plugin.

Always also load: `skills/personas/telnyx-consultant.md`

## Sub-Files (load the relevant one for your task)

| File | Covers |
|------|--------|
| `SMS.md` | SMS/MMS, Messaging Profile, 10DLC, CASL compliance |
| `VOICE.md` | Call Control API, TeXML, IVR, call recording |
| `AI-ASSISTANTS.md` | Voice AI assistants, routing, prompts, design |
| `PHONE-NUMBERS.md` | Purchase, port, manage DID/toll-free numbers |
| `SIP-WEBRTC.md` | SIP trunking, WebRTC SDK, click-to-call |
| `STORAGE-INTEL.md` | Number Intelligence lookup, Cloud Storage |
| `OBSERVABILITY.md` | Debugging SMS/voice, webhook events, portal tools |
| `DYNAMIC-API-CLI.md` | Dynamic API access pattern, Telnyx CLI local dev |
| `APPROVAL-GATES.md` | Tool classification: SAFE / LEVEL 1 / 2 / 3 gates |
| `COMPLIANCE.md` | CASL, PIPEDA/Law 25, TCPA opt-out and consent rules |

---

## Platform Overview

Telnyx is a cloud communications platform providing:
- **SMS/MMS** — programmatic text messaging
- **Voice** — outbound/inbound calls via Call Control API or TeXML
- **AI Assistants** — voice bots that answer and make phone calls
- **SIP Trunking** — connecting PBX or softphone systems to the PSTN
- **WebRTC** — browser/mobile calling via `@telnyx/webrtc` SDK
- **Phone Numbers** — purchase, port, and manage DID/toll-free numbers
- **Number Intelligence** — lookup line type, CNAM, carrier
- **Cloud Storage** — S3-compatible object storage for recordings and media

**Key concept — Connections:**
A Connection is the routing layer between your phone numbers and your application.
All calls and messages flow through a Connection. Three connection types:
- **Call Control Connection** — for programmatic voice (Call Control API / TeXML)
- **Fax Connection** — for fax (not covered here)
- **IP/SIP Connection** — for SIP trunking

Numbers are assigned to one Connection. Messages are routed via a Messaging Profile.
