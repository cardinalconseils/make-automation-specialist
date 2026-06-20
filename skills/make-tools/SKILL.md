---
name: make-tools
description: Complete reference for all Make.com tools available via MCP and CLI. Classifies every operation as deterministic (read-only, safe) or non-deterministic (write, side effects, requires approval). Defines tool selection rules and system design protocol.
---

# Make.com Tool Reference

## Sub-files

- `MAKE-TOOLS-PROTOCOL.md` — Module selection rule, tool selection (MCP vs CLI), system design protocol
- `MAKE-TOOLS-READ.md` — All deterministic (read-only) MCP and CLI tools
- `MAKE-TOOLS-WRITE.md` — All non-deterministic (write/destructive) MCP and CLI tools

## Module Selection Rule — Native First, Always

**Never use the HTTP module if a native Make.com module exists for the service.**

| Situation | Wrong | Right |
|-----------|-------|-------|
| Sending a Slack message | HTTP module → POST to Slack API | Slack → Send a Message |
| Creating a Google Sheet row | HTTP module → POST to Sheets API | Google Sheets → Add a Row |
| Sending an email via Gmail | HTTP module → Gmail REST API | Gmail → Send an Email |
| Creating a HubSpot contact | HTTP module → POST to HubSpot API | HubSpot → Create a Contact |

HTTP module is acceptable only when:
- The service has no Make.com app at all
- The specific API endpoint has no matching native module
- The user explicitly requires it for a one-time custom API

## Tool Selection Rule — MCP vs CLI

**MCP first.** Use MCP tools by default — structured data, automatic auth, fully typed.

**Use the CLI (`make-cli`) when:**
- Doing bulk operations on many scenarios at once (scripting loops)
- MCP tool is unavailable or returning errors
- You need raw blueprint JSON for file-based manipulation
- Setting up SDK apps (custom app development)

## Connection Verification

Before using any connection in a new scenario, verify it is working:

```bash
make-cli connections verify --connection-id {id}
```

A broken connection will cause every module using it to fail silently until the first run.
