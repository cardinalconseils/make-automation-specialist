# Slash Commands

Every command file in `commands/`. Keep this table in sync when adding or
removing one — a command documented here but missing from `commands/` is worse
than an undocumented command, because Claude will try to route to it.

## Build and design

| Command | Agent | Description |
|---------|-------|-------------|
| `/kickstart` | kickstart-planner | Plan-mode discovery, then generate context artifacts |
| `/factory` | scenario-orchestrator | Full pipeline: kickstart → bootstrap → design → sprint |
| `/factory-phases` | scenario-orchestrator | Phase reference for the factory flow |
| `/factory-sprint` | scenario-orchestrator | Sprint execution phase only |
| `/make` | automation-specialist | Start a new automation conversation |
| `/make-flow` | automation-specialist | Conversation flow reference |
| `/plan` | automation-planner | Generate a plan with cost and risk, execute nothing |
| `/build` | scenario-builder | Build chosen scenarios from the post-kickstart backlog |
| `/next` | scenario-builder | Build the next unbuilt backlog item |
| `/agent` | ai-agent-builder | Design and build an AI agent in Make.com |

## Inspect and repair

| Command | Agent | Description |
|---------|-------|-------------|
| `/audit` | scenario-auditor | Audit one or all scenarios |
| `/audit-checklist` | scenario-auditor | The audit checklist itself |
| `/diagnose` | failure-diagnostician | Classify a failure against the taxonomy before fixing |
| `/taxonomy` | taxonomy-curator | Add or update a failure pattern |
| `/blueprint-review` | scenario-auditor | Review a blueprint before pushing |
| `/existing-scenarios` | scenario-reporter | Discover what already exists in the workspace |
| `/status` | automation-specialist | Workspace status, usage, recent logs |
| `/migrate` | scenario-orchestrator | Move scenarios between teams or accounts |

## Report

| Command | Agent | Description |
|---------|-------|-------------|
| `/diagram` | scenario-reporter | Mermaid flowchart of a scenario |
| `/report` | scenario-reporter | Written plain-language report |

## Communications

| Command | Agent | Description |
|---------|-------|-------------|
| `/telnyx` | telnyx-agent | Telnyx platform configuration |
| `/sms` | telnyx-agent | SMS setup and sending |
| `/voice` | telnyx-agent | Voice and SIP configuration |
| `/voice-flows` | telnyx-agent | Voice flow reference |

## Meta

| Command | Agent | Description |
|---------|-------|-------------|
| `/research` | deep-researcher | Multi-hop research on an unfamiliar service |
| `/version` | — | Show plugin version |

## Repo layout

```
commands/    slash command definitions
agents/      subagent definitions (27)
skills/      invocable skills
taxonomy/    failure taxonomy, loaded before any fix (tracked)
.claude/rules/  behaviour rules, indexed from CLAUDE.md
scripts/     bump-version.sh · smoke-test.sh · install-hooks.sh · make-sdk.sh
.make/       workspace state, logs, blueprint mirrors — GITIGNORED, local only
```
