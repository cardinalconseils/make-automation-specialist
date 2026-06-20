# Make.com Automation Specialist — Claude Code Plugin

A Claude Code plugin that turns any project into an intelligent Make.com automation
workspace. Describe a business problem in plain English, Claude plans the automation,
you approve it, and Claude builds it in Make.com.

---

## What this plugin does

- **Build new automations** — Conversation → plan with cost estimates → your approval → Claude builds it.
- **Audit existing scenarios** — Finds issues, proposes ranked fixes, executes after approval.
- **Generate diagrams** — Mermaid flowcharts saved to `.make/diagrams/`.
- **Compliance assessment** — Auto-detects GDPR, Quebec Law 25, PCI-DSS, HIPAA.
- **Telegram alerts** — Pinged on Telegram when an automation fails and can't self-recover.
- **Full audit trail** — Everything Claude plans, builds, or fixes goes to `.make/` with timestamps.

---

## Quick start

```bash
claude plugin install make-automation-specialist@make-automation-specialist --scope user
```

Then open any project in Claude Code. The `on-project-open` hook runs automatically.

See [docs/README-setup.md](docs/README-setup.md) for full installation and MCP configuration.

---

## Slash commands

| Command | What it does |
|---------|-------------|
| `/make [description]` | Start an automation — discover, plan, approve, build. |
| `/build [description]` | Alias for `/make`. |
| `/plan [description]` | Plan with cost estimate and diagram — no build. |
| `/factory [idea]` | Full portfolio: Kickstart → Bootstrap → Design → Sprint. |
| `/kickstart [idea]` | Discovery + context artifacts only. |
| `/agent [description]` | Design and build an AI-powered Make.com agent. |
| `/audit [scenario]` | Audit scenarios; omit argument for full workspace. |
| `/fix [issue]` | Target a specific issue via failure taxonomy. |
| `/diagnose [error]` | Taxonomy-first error classification and fix. |
| `/research [service]` | Integration research before building. |
| `/diagram [scenario]` | Mermaid flowchart (read-only). |
| `/report [scenario]` | Plain-language scenario report (read-only). |
| `/telnyx [task]` | Telnyx platform management. |
| `/status` | Live workspace dashboard. |
| `/make:version` | Show installed vs latest version. |
| `/make:migrate` | Detect version gap and update. |

See [docs/README-commands.md](docs/README-commands.md) for full command reference with examples.

---

## Further reading

- [docs/README-setup.md](docs/README-setup.md) — Installation, MCP config, environment variables
- [docs/README-architecture.md](docs/README-architecture.md) — How it works, hooks, agents, file structure
- [docs/README-commands.md](docs/README-commands.md) — Full command reference with examples
