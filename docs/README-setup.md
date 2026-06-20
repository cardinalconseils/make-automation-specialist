# Setup Guide — Make.com Automation Specialist

## Installation

Run once to install for all projects:

```bash
claude plugin install make-automation-specialist@make-automation-specialist --scope user
```

Or for a single project only (run from inside that project):

```bash
claude plugin install make-automation-specialist@make-automation-specialist --scope project
```

Verify installation:

```bash
claude plugin list
```

You should see `make-automation-specialist` in the list.

> **First install only:** Add this to `~/.claude/settings.json` under `extraKnownMarketplaces`:
> ```json
> "make-automation-specialist": {
>   "source": { "source": "github", "repo": "cardinalconseils/make-automation-specialist" }
> }
> ```

---

## Step 1 — Add your Make.com credentials

```bash
cp .env.example .env
```

Open `.env` and set:

```
MAKE_API_KEY=your_make_api_key_here
MAKE_TEAM_ID=your_make_team_id_here
```

**Where to find these:**
- API Key: Make.com → profile (top right) → API → Generate a token
- Team ID: The number after `/team/` in your Make.com URL

---

## Step 2 — Add Make.com MCP to Claude Code

Open `~/.claude/claude_desktop_config.json` and add inside `"mcpServers"`:

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

## Step 3 — (Optional) Set up Telegram alerts

Lets Claude ping you when something breaks and can't auto-fix.

1. Search Telegram for `@BotFather` → `/newbot` → save the **API token**
2. Start a chat with your bot, then visit:
   `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates` — find your **chat ID**
3. Add to `.env`:
   ```
   TELNYX_API_KEY=your_telnyx_api_key
   TELEGRAM_CHAT_ID=your_telegram_chat_id
   ```

---

## Step 4 — Open the project in Claude Code

The `on-project-open` hook runs automatically and:
- Detects connected MCPs
- Maps your Make.com workspace (teams, scenarios)
- Creates the `.make/` folder structure
- Tells you if anything is missing

---

## Optional integrations

| Service | What it adds | Env vars needed |
|---------|-------------|----------------|
| Supabase | Persistent logs and execution history | `SUPABASE_URL`, `SUPABASE_KEY` |
| n8n | Fallback platform when Make.com has limits | `N8N_BASE_URL`, `N8N_API_KEY` |
| GitHub | Read project context and open PRs | `GITHUB_TOKEN` |