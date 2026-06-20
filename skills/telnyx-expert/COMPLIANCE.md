# Telnyx Expert — Compliance (CASL, PIPEDA, TCPA)

Part of `skills/telnyx-expert/`. See `SKILL.md` for full index.

---

## CASL — Canada's Anti-Spam Legislation

Applies to any commercial electronic message sent to a Canadian number or address.

### Express Consent Required

You must have **express written consent** before sending commercial SMS to Canadian
numbers. Implied consent (prior business relationship) has a 2-year window.

**Minimum consent record fields:**
- Phone number
- Date/time of consent
- Method of consent (webform, verbal with recording, SMS keyword)
- Consent language shown to subscriber

### Opt-Out Handling (mandatory)

Every message must include a clear opt-out mechanism:
- For SMS: "Reply STOP to unsubscribe"
- Process opt-outs within 10 business days
- Never send again after opt-out unless new express consent obtained

### Recommended Make.com Pattern

```
[Inbound SMS webhook]
  → [Filter: text contains "STOP"]
      → [Data Store: set opted_out=true, timestamp=now]
      → [Telnyx: send_message "You have been unsubscribed."]
      → [STOP — do not send further messages]
```

Store consent records for minimum 3 years. CASL fines up to $10M CAD per violation.

> **This is not legal advice. Review your CASL compliance with qualified legal counsel.**

---

## PIPEDA / Quebec Law 25

Applies to personal information collected in the course of commercial activities.

### Applies When

Automation collects phone numbers, transcripts, recordings, names, or location data.

### Key Requirements

- **Purpose limitation** — only collect what you need
- **Consent** — inform users what you collect and why
- **Data minimization** — delete when no longer needed
- **Breach notification** — report breaches to Privacy Commissioner within 72 hours

### Recommended Safeguards

- Store transcripts in Telnyx Cloud Storage (Canadian region if available)
- Apply retention policy: auto-delete recordings after 90 days unless required longer
- Do not log full phone numbers in plaintext Make.com data stores without encryption

> **This is not legal advice. Review with your legal team before processing personal data.**

---

## TCPA — US Telephone Consumer Protection Act

Applies to SMS sent to US numbers.

### Requirements

- Express written consent before A2P (automated) SMS
- Must include opt-out instructions in every marketing message
- 10DLC registration required for bulk SMS (see `SMS.md`)
- Quiet hours: no messages between 9pm–8am local time of recipient

### STOP Keyword (Telnyx handles automatically for 10DLC campaigns)

Telnyx automatically processes STOP, HELP, and INFO keywords for registered 10DLC
campaigns. You must still handle opt-outs at the application level.

> **This is not legal advice. TCPA carries statutory damages of $500–$1,500 per message.**

---

## Compliance Checklist Before Sending

- [ ] Consent obtained and recorded with timestamp
- [ ] Opt-out mechanism in every marketing message
- [ ] Opt-out processing flow built in Make.com
- [ ] 10DLC approved (US) or toll-free verified before bulk sends
- [ ] Retention/deletion policy defined for recordings and transcripts
- [ ] Legal review completed for your use case
