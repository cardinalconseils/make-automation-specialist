# Changelog

## [1.14.0] — 2026-06-21

### Features
- post-kickstart build workflow — /build, /next, scenario-builder-worker
- deterministic kickstart artifact gate
- hybrid workflow — blueprint-fetch, blueprint-push, pre-push-guard
- brainstorm-sharp + discovery-to-blueprint + council-of-5 — pre-flight discovery chain


## [1.13.0] — 2026-06-20

### Features
- deterministic kickstart artifact gate
- brainstorm-sharp + discovery-to-blueprint + council-of-5 — pre-flight discovery chain

### Other
- Merge remote-tracking branch 'origin/release/v1.5.1' into release/v1.5.1


## [1.12.0] — 2026-06-20

### Features
- hybrid workflow — blueprint-fetch, blueprint-push, pre-push-guard
- brainstorm-sharp + discovery-to-blueprint + council-of-5 — pre-flight discovery chain

### Maintenance
- enforce 100-line file rule — split 40+ oversized files across agents, skills, commands, scripts, and taxonomy


## [1.11.0] — 2026-06-20

### Features
- `blueprint-fetch` skill — `/blueprint-fetch` entry point for pulling live blueprints from Make API into `.make/scenarios/{id}.json` before any local editing begins
- `blueprint-push` skill — `/blueprint-push` unified push cycle: review gate → plan check → API push → `isinvalid` validation → log creation. The only sanctioned path for writing blueprint changes to Make
- `pre-push-guard` hook (`before.agent.respond`) — workflow gate that blocks any local blueprint push unless a plan file exists in `.make/plans/` and blueprint-review was run this session

### Architecture
Completes the hybrid workflow protocol: MCP tools for reads, local JSON + API push for writes. The `blueprint-fetch` → edit → `blueprint-push` cycle is now fully encoded as skills and enforced by the `pre-push-guard` hook.

## [1.10.1] — 2026-06-16


## [1.10.0] — 2026-06-15

### Features
- `/make:version` command (`commands/version.md`) — show installed vs latest plugin version, detect staleness, surface upgrade path
- `/make:migrate` command (`commands/migrate.md`) — detect version gap, show CHANGELOG entries for missed releases, guide upgrade
- `commands/status.md` — wired plugin version line into status output
- `scripts/bump-version.sh` — added post-release checklist (update instructions + in-project verification step)

## [1.9.0] — 2026-06-15

### Features
- wire failure taxonomy system into agentic workflow


## [1.8.0] — 2026-06-15

### Features
- **Make Failure Taxonomy** — `taxonomy/make-failure-taxonomy.md` — 30+ classified failure patterns across 12 categories (HTTP, MAKE engine, CONN, DATA, TRIG, RATE, EXEC, ROUTER, ITER, BLUEPRINT, APP, PATTERN)
- **`failure-diagnostician` agent** — taxonomy-first diagnosis: classify → cite → fix → explain
- **`taxonomy-curator` agent** — add, merge, audit taxonomy entries
- **`failure-diagnostician` skill** — quick-lookup table + diagnosis protocol
- **`blueprint-review` skill** — 7-point pre-push blueprint validation checklist
- **`taxonomy-updater` skill** — guided entry creation with format enforcement
- **`failure-patterns` skill** — 8 cross-cutting failure patterns with prevention checklists
- **`on-error-classify` hook** — deterministic: auto-classifies Make errors in context before agent responds
- **`/diagnose` command** — dispatch failure diagnostician
- **`/blueprint-review` command** — pre-push blueprint audit
- **`/taxonomy` command** — view, search, add, audit taxonomy
- **`failure-taxonomy-protocol` rule** — enforces taxonomy-first behavior across all agents

## [1.7.0] — 2026-06-12

### Features
- port Claude-Starter hardening patterns — rules, hooks, skills, agent, smoke-test


## [1.6.0] — 2026-06-12

### Features
- add formula-expert/error-handler refs to orchestrator; expand alert-dispatcher to 3-tier


## [1.5.2] — 2026-06-12


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