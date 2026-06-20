---
name: scenario-reader
description: Parses Make.com scenario blueprints into structured, analyzable form. Detects issues (missing error handlers, hardcoded credentials, inefficient triggers) and flags data sensitivity for compliance scanning.
---

# Skill: scenario-reader

Parses Make.com scenario blueprints into structured, analyzable form.
Input: raw Make.com blueprint JSON. Output: structured representation.

## Input

Make.com scenario blueprint from MCP response. Contains:
- `flow` array — ordered list of modules
- `metadata` — scenario settings, scheduling, status
- `connections` — module-to-module data mappings

## Output Structure

See [output-schema.md](output-schema.md) for the full JSON output structure.

## Issue Detection Rules

### Critical (must fix)
- Module with `can_fail: true` and `has_error_handler: false`
- Trigger module type is `watch` on a service that supports `webhook` (inefficient polling)
- Any module with hardcoded API key, password, or token in config values
- Circular reference in module routing (infinite loop risk)
- Module reading from connection not present in workspace

### Warning (should fix)
- No filters before modules that charge per API call (e.g., OpenAI, external APIs)
- Scenario has no notification path on any error handler
- Iterator without array aggregator (data leaks between runs)
- Using HTTP module where native app module exists
- More than 15 modules in single scenario (consider splitting)
- Schedule trigger running more frequently than data actually changes

### Info (nice to have)
- Last run > 30 days ago (possibly orphaned)
- Module count > 10 (document the flow)
- No scenario description set in Make.com

## Data Sensitivity Detection

Mark `touches_personal_data: true` if any module:
- Connects to a CRM (HubSpot, Salesforce, Pipedrive)
- Processes form submissions with fields: name, email, phone, address
- Reads from or writes to HR systems
- Handles EU or Quebec user data (check for EU region connections)

Mark `touches_payment_data: true` if any module:
- Connects to Stripe, PayPal, Shopify
- Contains fields: card, payment, invoice, billing

Mark `touches_health_data: true` if any module:
- Connects to health/medical services
- Contains fields: diagnosis, patient, health, medical

## Hardcoded Credential Detection

Scan all module config values for patterns:
- Strings matching API key patterns (length > 20, mixed alphanumeric, no spaces)
- Email/password fields with literal values
- Authorization header values that are not variable references
- Any config value containing "secret", "key", "token", "password"

Flag as critical issue if found.
