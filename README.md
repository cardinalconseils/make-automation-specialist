# Make.com Automation Specialist — Claude Code Plugin

A Claude Code plugin that turns any project into an intelligent Make.com automation workspace. You describe a business problem in plain English, Claude plans the automation, you approve it, and Claude builds it in Make.com.

---

## What this plugin does

- **Build new automations** — Have a conversation with Claude, get a full automation plan with cost estimates, approve it, Claude builds it in Make.com.
- **Audit existing scenarios** — Claude reads your Make.com scenarios, finds issues, proposes fixes, executes after your approval.
- **Generate diagrams** — Visual Mermaid flowcharts of any scenario, saved to `.make/diagrams/`.
- **Compliance assessment** — Auto-detects GDPR, Quebec Law 25, PCI-DSS, and HIPAA requirements when deployed in a project.
- **Telegram alerts** — If an automation fails and can't auto-recover, you get pinged on Telegram.
- **Full audit trail** — Everything Claude plans, builds, or fixes is saved to the `.make/` folder with timestamps.

---

## Installation

Run this command once to install the plugin for all your projects:

```bash
claude plugin install /Users/pmc/Documents/DEV/make.com --scope user
```

Or install it only for one specific project (run from inside that project):

```bash
claude plugin install /Users/pmc/Documents/DEV/make.com --scope project
```

To verify it installed:

```bash
claude plugin list
```

You should see `make-automation-specialist` in the list.

---

## Setup (Step-by-step)

### Step 1 — Add your Make.com credentials

Copy the example env file and fill in your API keys:

```bash
cp .env.example .env
```

Open `.env` and set:

```
MAKE_API_KEY=your_make_api_key_here
MAKE_TEAM_ID=your_make_team_id_here
```

**Where to find these:**
- Make.com API Key: Go to Make.com → your profile (top right) → API → Generate a token
- Team ID: In Make.com, look at your URL when in your team — it's the number after `/team/`

---

### Step 2 — Add Make.com MCP to Claude Code

Open your Claude Code MCP config file. On Mac it's at:

```
~/.claude/claude_desktop_config.json
```

Add this inside the `"mcpServers"` block:

```json
"make": {
  "command": "npx",
  "args": ["-y", "@anthropic-ai/mcp-server-make"],
  "env": {
    "MAKE_API_KEY": "your_make_api_key_here",
    "MAKE_TEAM_ID": "your_make_team_id_here"
  }
}
```

---

### Step 3 — (Optional but recommended) Set up Telegram alerts

This lets Claude ping you on Telegram when something breaks and can't be auto-fixed.

1. Open Telegram and search for `@BotFather`
2. Type `/newbot` and follow the steps to create a bot — save the **API token** it gives you
3. Start a chat with your new bot, then visit:
   `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
   to find your **chat ID** (it's the number next to `"id":`)
4. Add to your `.env`:
   ```
   TELNYX_API_KEY=your_telnyx_api_key
   TELEGRAM_CHAT_ID=your_telegram_chat_id
   ```

---

### Step 4 — Open this project in Claude Code

That's it. The `on-project-open` hook runs automatically and:
- Detects which MCPs you have connected
- Maps your Make.com workspace (teams, scenarios)
- Creates the `.make/` folder structure
- Tells you if anything is missing

---

## How to use it

Once set up, just talk to Claude naturally. Or use these slash commands:

| Command | What it does |
|---------|--------------|
| `/make` | Start a conversation to build a new automation |
| `/build` | Same as `/make` |
| `/audit` | Analyze your existing Make.com scenarios for issues |
| `/fix` | Find and fix a specific scenario |
| `/plan` | Generate an automation plan without executing anything |
| `/diagram` | Create a visual flowchart of a scenario |
| `/report` | Generate a written report of a scenario |

**Example conversations:**

> "I want to automatically send a Slack message every time a new lead fills out my Typeform"

> "Audit all my Make.com scenarios and tell me what could break"

> "Build me an AI agent that summarizes my Gmail emails every morning"

---

## Where Claude saves its work

Everything goes into the `.make/` folder inside your project:

```
.make/
  plans/       ← Automation plans waiting for your approval
  logs/        ← Execution history with timestamps and costs
  scenarios/   ← Saved scenario blueprints
  changelog/   ← Record of every change Claude made
  audits/      ← Audit reports from /audit runs
  compliance/  ← Compliance scan results
  diagrams/    ← Mermaid flowcharts
```

---

## Optional integrations

The plugin works without these, but they unlock more capabilities:

| Service | What it adds | Env var needed |
|---------|-------------|----------------|
| Supabase | Persistent storage for logs and execution history | `SUPABASE_URL`, `SUPABASE_KEY` |
| n8n | Fallback automation platform when Make.com has limits | `N8N_BASE_URL`, `N8N_API_KEY` |
| GitHub | Read project context and open PRs for automation configs | `GITHUB_TOKEN` |

---

## Plugin structure (for the curious)

```
plugin.json              ← Plugin manifest
CLAUDE.md                ← Behavior rules loaded in every session
agents/
  automation-specialist  ← Main agent (conversation → plan → build)
  scenario-auditor       ← Audit + fix existing scenarios
  automation-planner     ← Plan generation only (no execution)
  scenario-reporter      ← Diagrams and reports (read-only)
skills/
  project-discoverer     ← First-run workspace mapping
  plan-builder           ← Maps requirements to Make.com modules
  scenario-reader        ← Parses blueprints, detects 15+ issue types
  diagram-generator      ← Mermaid flowchart builder
  compliance-scanner     ← GDPR, Quebec Law 25, PCI-DSS, HIPAA
  cost-estimator         ← Operation counts and API cost estimates
  alert-dispatcher       ← Telegram alerts via Telnyx
  execution-logger       ← Audit trail and changelog writer
hooks/
  on-project-open        ← Auto-runs on session start
  pre-execute            ← Approval gate (nothing executes without your OK)
  post-execute           ← Logs results, sends alerts on failure
  on-error               ← 3-tier auto-recovery
```

---

## How Claude behaves

A few important things to know:

1. **Claude always asks before doing anything.** It will show you the full plan — including what it will build, estimated costs, and links to relevant Make.com documentation — before touching anything.

2. **Everything is explained simply.** Claude assumes you are not a Make.com expert. No jargon.

3. **Guardrails are always included.** Every automation Claude builds includes error handling, observability, and retry logic — you don't have to ask.

4. **If something breaks,** Claude tries to fix it automatically. If it can't, it logs the error and sends you a Telegram message.

---

## Need help?

Just ask Claude: *"What can you help me with?"* and it will walk you through everything.
