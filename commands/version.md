---
description: Show installed and latest plugin version, detect staleness, and surface the upgrade path. Read-only.
---

# /make:version — Plugin Version Check

Read-only. No approval needed. No MCP calls required.

## Source of Truth

- **Installed version:** `~/.claude/plugins/installed_plugins.json` → `make-automation-specialist` entry
- **Latest version on disk:** `{installPath}/plugin.json` → `version` field
- **Changelog:** `{installPath}/CHANGELOG.md` — written by `scripts/bump-version.sh` on every release

Both files are maintained by `scripts/bump-version.sh`. This command reads them — that is the wire.

## Steps

1. Read `~/.claude/plugins/installed_plugins.json` using the Bash tool:
   ```bash
   cat ~/.claude/plugins/installed_plugins.json
   ```
   Find all entries where `name` or key matches `make-automation-specialist`. Note:
   - `version` — what Claude Code has registered as installed
   - `installPath` — where the plugin files live on disk
   - `scope` — `user` or `project`
   - `projectPath` — if scope is `project`

2. Read `{installPath}/plugin.json` to get the version currently on disk (may differ if git was pulled manually without a Claude re-install):
   ```bash
   node -p "require('{installPath}/plugin.json').version"
   ```

3. Read the first 40 lines of `{installPath}/CHANGELOG.md` to get the most recent release notes.

4. Display the version panel:

```
MAKE AUTOMATION SPECIALIST — VERSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Plugin:     make-automation-specialist

INSTALLED
  Registered version:  {installed_plugins.json version}
  On-disk version:     {plugin.json version}
  Install path:        {installPath}
  Scope:               {user / project}

STATUS
  {✅ Up to date — registered matches on-disk}
  {⚠️  Stale — registered {X} but disk has {Y}. Run: claude plugin update make-automation-specialist}
  {❌ Not found — plugin not registered in installed_plugins.json}

LATEST RELEASE NOTES
  {first CHANGELOG.md entry — version + date + bullet list}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run /make:migrate to see full upgrade steps if behind.
```

## Stale Detection Logic

- `registered == on-disk` AND both match latest → ✅ Up to date
- `registered != on-disk` → ⚠️ Claude Code registered an older version. The disk has been updated (e.g., git pull) but `claude plugin update` wasn't run. Show the mismatch and prompt.
- Entry missing from `installed_plugins.json` → ❌ Not installed in this scope.

## Multiple Scopes

If the plugin appears in both `user` and `project` scope, show both rows. Note which scope is active for this session (project scope wins if present).
