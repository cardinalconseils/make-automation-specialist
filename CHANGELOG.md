# Changelog

## [1.5.1] — 2026-06-12

### Fixes
- version bump, update checks, CHANGELOG, and README install instructions

### Other
- Merge pull request #1 from cardinalconseils/release/v1.0.1


## [1.4.0] — 2026-06-12

### Features
- Plugin now installable from GitHub via `claude plugin install make-automation-specialist@make-automation-specialist`
- Added `extraKnownMarketplaces` support for remote install without cloning

### Fixes
- Version bump now syncs both `plugin.json` and `.claude-plugin/plugin.json` so update checks work correctly
- Removed pre-commit auto-bump that was causing double version increments on every ship

### Maintenance
- README updated with correct remote install command and marketplace registration instructions

## [1.0.0] — 2026-06-09

### Features
- Initial release — Make.com Automation Specialist plugin
- Conversational automation building with approval gates
- Scenario auditing and compliance scanning
- Native-first module selection (no HTTP by default)
- Composio connector fallback layer
- Telegram alerting via Telnyx on automation failure
- Cost estimation and operation tracking
- Full `.make/` audit trail