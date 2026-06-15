---
description: Detect version gap between installed and latest plugin, show CHANGELOG entries for missed releases, and guide the upgrade. Read-only until user confirms update.
---

# /make:migrate — Plugin Migration Guide

Reads CHANGELOG.md (written by `scripts/bump-version.sh` on every release) and compares it against the registered installed version. Shows exactly what changed in missed releases. No MCP calls. No Make.com writes.

## Source of Truth

Same as `/make:version`:
- Installed version → `~/.claude/plugins/installed_plugins.json`
- Latest on disk → `{installPath}/plugin.json`
- Release history → `{installPath}/CHANGELOG.md`

`scripts/bump-version.sh` is the writer. `/make:migrate` is the reader. That is the wire.

## Steps

### 1. Resolve versions

Run the same version check as `/make:version`:
```bash
cat ~/.claude/plugins/installed_plugins.json
node -p "require('{installPath}/plugin.json').version"
```

If already at latest: show confirmation and exit early (see Early Exit below).

### 2. Parse CHANGELOG for missed versions

Read the full `{installPath}/CHANGELOG.md`. Extract every `## [X.Y.Z]` section where `X.Y.Z` is newer than the installed version (semver comparison). Collect them in descending order (newest first).

### 3. Display migration panel

```
MAKE AUTOMATION SPECIALIST — MIGRATION GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installed:  {installed version}
Latest:     {on-disk version}
Gap:        {N} release(s) behind

CHANGES SINCE YOUR VERSION
━━━━━━━━━━━━━━━━━━━━━━━━━━
{For each missed release, newest first:}

### [{version}] — {date}
{paste the CHANGELOG section verbatim}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UPGRADE

  Step 1 — Pull latest plugin files (if not already done):
    cd {installPath} && git pull

  Step 2 — Register the update with Claude Code:
    claude plugin update make-automation-specialist

  Step 3 — Restart this session so new agent/skill wiring takes effect.

After upgrading, run /status to verify the workspace is healthy.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 4. Offer to run the update

Ask: "Ready to run `claude plugin update make-automation-specialist` now? (yes / no)"

- **Yes** → Run the command via Bash, then re-read `installed_plugins.json` to confirm the new version was registered. Show before/after.
- **No** → Print the manual upgrade steps and close.

## Early Exit — Already Up to Date

If `installed version == on-disk version`:

```
MAKE AUTOMATION SPECIALIST — MIGRATION GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Already at latest: {version}

No migration needed.

Last release:
{first CHANGELOG.md section}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Agent Wiring Notes

This command does not dispatch a sub-agent. It runs inline within the active session.

New versions may add or rewire skills and agents. After updating:
- New skills loaded at agent startup: check `agents/*.md` for updated "Skills Loaded at Startup" sections
- New hooks: check `hooks/` — hooks require session restart to activate
- New taxonomy entries: available immediately via `taxonomy/make-failure-taxonomy.md`
- New PATTERN-xxx codes: check `skills/failure-patterns/SKILL.md`
