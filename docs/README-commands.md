# Command Reference — Make.com Automation Specialist

## Build

| Command | What it does |
|---------|-------------|
| `/make [description]` | Start an automation conversation. Discovers workspace, designs scenario, gets approval, builds. |
| `/build [description]` | Alias for `/make`. |
| `/plan [description]` | Generate a detailed plan with cost estimate, risk level, and Mermaid diagram — no build. |
| `/factory [idea]` | Full automation factory: Kickstart → Bootstrap → System Design → Sprint. |
| `/kickstart [idea]` | Discovery only — guided interview + context artifacts. Does not build. |
| `/agent [description]` | Design and build an AI-powered agent inside a Make.com scenario. |

## Audit & Fix

| Command | What it does |
|---------|-------------|
| `/audit [scenario]` | Audit scenarios for errors, missing handlers, inefficiencies, compliance risks. Omit for full workspace. |
| `/fix [issue]` | Target a specific issue. Classifies via failure taxonomy before proposing any fix. |
| `/diagnose [error]` | Taxonomy-first diagnosis. Classifies by pattern code, states expected vs actual, prescribes fix. |
| `/blueprint-review` | 7-point pre-push review of a blueprint JSON before sending to Make.com API. |

## Research & Report

| Command | What it does |
|---------|-------------|
| `/research [service]` | Research an integration — native app availability, API docs, rate limits, webhook support, gotchas. |
| `/diagram [scenario]` | Generate a Mermaid flowchart for a scenario. Read-only. |
| `/report [scenario]` | Plain-language report: data flow, performance stats, observations. Read-only. |

## Telnyx / Communications

| Command | What it does |
|---------|-------------|
| `/telnyx [task]` | Telnyx platform management — phone numbers, connections, AI assistants, call control apps. |
| `/sms [task]` | SMS setup, troubleshooting, and compliance via Telnyx. |
| `/voice [task]` | Voice calls, IVR, AI receptionist, SIP trunking via Telnyx. |

## Taxonomy

| Command | What it does |
|---------|-------------|
| `/taxonomy` | View, search, or update the Make Failure Taxonomy (80+ patterns, 12 categories). |

## Workspace & Plugin

| Command | What it does |
|---------|-------------|
| `/status` | Live workspace dashboard — scenarios, operations usage, connections, recent runs, pending plans. |
| `/make:version` | Show installed vs latest plugin version. Flags staleness with the upgrade command. |
| `/make:migrate` | Detect version gap, show CHANGELOG for every missed release, run the update. |

---

## Example conversations

> "I want to automatically send a Slack message every time a new lead fills out my Typeform"

> "Audit all my Make.com scenarios and tell me what could break"

> "Build me an AI agent that summarizes my Gmail emails every morning"

> "My Google Sheets module is failing with 403 — what's wrong?"
