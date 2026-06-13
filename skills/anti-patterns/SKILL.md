---
name: anti-patterns
description: "Catalog of Make.com automation anti-patterns — detect and reject before building or approving. Covers triggers, data flow, error handling, and scenario structure."
allowed-tools: Read, Grep, Glob
---

# Make.com Automation Anti-Patterns

Detect these before proposing or approving any automation. Each entry:
**detect** the signal → **name** it → **reject** → **fix**.

---

## Trigger Anti-Patterns

### Polling When Webhooks Are Available
**Detect:** Scheduled trigger fetching data from a service that offers webhooks.
**Reject:** "Check Stripe for new payments every 15 minutes."
**Fix:** Use Stripe webhooks. Polling wastes operations and adds latency.

### Webhook Without Verification
**Detect:** Webhook trigger with no signature/token validation module.
**Reject:** Any public webhook that accepts any payload without checking it came from the right source.
**Fix:** Add an HTTP header check or IP filter module immediately after the webhook trigger.

---

## Data Flow Anti-Patterns

### Storing Data You Never Read Back
**Detect:** Data store created to log events that no other scenario ever queries.
**Reject:** Writing every webhook payload to a data store "just in case."
**Fix:** Write to a Google Sheet or external logging service. Data stores cost operations on every write AND read.

### Mapping the Same Field Twice
**Detect:** A field extracted in module 2, ignored, then re-extracted from the original bundle in module 7.
**Reject:** Any scenario where the same source field is mapped multiple times across unrelated modules.
**Fix:** Extract once, store in a Set Variable, reference the variable throughout.

### Giant JSON in a Text Field
**Detect:** A full JSON object stringified and stored in a single text field.
**Reject:** `{"order_id":"123","items":[...],"customer":{...}}` as one field value.
**Fix:** Use a Make.com data structure with proper field typing.

---

## Error Handling Anti-Patterns

### Silent Error Swallowing
**Detect:** Error handler route with no alert module — just "Continue" or "Stop."
**Reject:** Any production scenario where errors vanish without notification.
**Fix:** Add an alert dispatcher (Telegram/email) to every error route before Stop.

### Retry Without Backoff
**Detect:** A retry module set to "immediate" or "1 second" for a rate-limited API.
**Reject:** Immediate retries on Stripe, OpenAI, or any API with rate limits.
**Fix:** Exponential backoff — 5s, 30s, 120s. Add a filter to detect 429 specifically.

### Error Handler That Hides Root Cause
**Detect:** An error route that catches all errors and sends a generic "something failed" alert.
**Reject:** Alerts that don't include the error message, module name, and bundle contents.
**Fix:** Include `{{error.message}}`, `{{error.module}}`, and the triggering data in every alert.

---

## Scenario Structure Anti-Patterns

### Mega-Scenario
**Detect:** One scenario doing 3+ unrelated business operations (e.g., syncing CRM, sending invoice, updating inventory).
**Reject:** Any scenario where disabling it would break unrelated business processes.
**Fix:** One scenario per business process. Use HTTP modules to chain them if needed.

### No Description on Modules
**Detect:** All modules have default names ("HTTP", "Google Sheets", "Iterator").
**Reject:** A scenario you can't read left-to-right without opening each module.
**Fix:** Name every module in plain English: "Get Stripe payment", "Find matching customer row".

### Hardcoded Credentials in Modules
**Detect:** API keys or tokens pasted directly into module fields instead of using a connection.
**Reject:** `Authorization: Bearer sk_live_abc123` in an HTTP module header.
**Fix:** Create a Make.com connection. Never put credentials in scenario fields.
