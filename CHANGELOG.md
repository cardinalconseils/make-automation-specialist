# Changelog

## [1.15.0] — 2026-08-24

### Fixed
- **Review gate had a hole on the path that mattered.** `pre-push-guard.js` only fired on
  `Bash` curl PUT, so scenario writes via MCP — `scenarios_create` / `scenarios_update`,
  the path every agent in this plugin actually uses — were never checked against a
  blueprint review. `blueprint-review` was advisory. `pre-execute-hook.js` now enforces it
  (`checkBlueprintReview` in `scripts/pre-execute-gates.js`).
- **Review sentinel is now bound to the blueprint.** The old `touch
  .make/logs/.blueprint-reviewed` meant reviewing blueprint A opened the gate for
  unrelated blueprint B for 24h. The sentinel is now JSON — `{ts, hash, verdict,
  scenario}` — and the gate passes only when `hash` equals the sha256 of the blueprint in
  the call, the review is under 24h old, and the verdict is not `FIX FIRST`. Hashing is
  key-order independent. Legacy touch-file sentinels are rejected, not silently accepted.
- `pre-push-guard.js` reads the same JSON sentinel, so both write paths share one record.
  (It has no blueprint in the tool input to hash against, so it verifies freshness and
  verdict only.)
- **The gates were registered nowhere portable, so none of them fired outside this repo.**
  `plugin.json`'s `hooks[]` array is descriptive metadata; Claude Code registers plugin
  hooks from `hooks/hooks.json`, and there wasn't one. The guards were wired only in this
  repo's own `.claude/settings.json` with absolute paths, so every deterministic gate —
  including the review gate above — fired *only when working inside the plugin's own
  repo*, never in the projects where scenarios actually get built. `hooks/hooks.json` now
  registers all four with `${CLAUDE_PLUGIN_ROOT}` so they travel with the plugin.
  Verified inert outside Make work: each guard exits 0 immediately unless the call is a
  Make write, a curl PUT to the Make scenarios endpoint, or a write into `.make/context/`.
- **`scripts/kickstart-plan-guard.js` had never fired.** Declared in `plugin.json` since
  v1.13.0 and registered nowhere. Now registered by `hooks/hooks.json`.

### Added
- **`skills/help-docs`** — live `help.make.com` retrieval via firecrawl, cached to
  `.make/research/help/{slug}.md` with a 14-day TTL. Covers what the MCP module API does
  not: router/iterator/aggregator semantics, error-handler directives, operations
  counting and billing, plan limits, AI Agent behaviour. Always cites the source URL;
  falls back to `WebFetch`, then to saying it cannot reach the docs. Never fabricates a
  URL. MCP module schemas stay authoritative for field specs.
- **`skills/execution-model`** — the deterministic-vs-indeterministic routing decision.
  Emits a Routing Verdict (`scenario` | `ai-agent` | `hybrid`) with the indeterministic
  step named and a one-line reason. `hybrid` — a deterministic shell with an AI Agent at
  the single judgement step — is documented as the expected default. Replaces keyword
  matching as the source of `ai_required`.
- **`scripts/blueprint-sentinel.js`** — writes the review sentinel using the gate's own
  canonical hash, so review and gate cannot disagree.
- **`.make/context/process-map.md`** — new kickstart artifact: the as-is business process
  as a Mermaid flowchart with actor swimlanes and every step tagged
  `[manual]` / `[system]` / `[decision]`, manual steps ranked as automation candidates.
  This is process mapping of the human workflow, distinct from `diagram-generator`, which
  renders scenarios that already exist.
- Entity-discovery questions in `kickstart-intake`, feeding a real `erDiagram` in
  `erd.md`. Previously `erd.md` held only a `flowchart LR` integration map — no entities,
  attributes, or cardinality. Both views now live in that file, plus an Entity Storage
  table with the rule that an entity with an existing system of record does not get a
  duplicate Make data store.

### Changed
- `plan-builder` gets the Routing Verdict before module selection; `routing_verdict` is
  on the AutomationPlan and in its guardrail checklist.
- `ai-agent-builder` and `ai-agent-designer` refuse to build on a `scenario` verdict and
  cite the reason, instead of building whatever was asked for.
- `docs-researcher` routes conceptual questions to `help-docs`; `failure-diagnostician`
  searches help.make.com before declaring a new taxonomy pattern.
- `automation-specialist` documents that scenario writes are gated in code.
- `plugin.json`: `firecrawl` added to `mcps.optional`.
- `.claude/settings.json`: dropped the duplicated absolute-path hook block now that
  `hooks/hooks.json` registers them; `enabledPlugins` stays. Prevents double-firing when
  working inside this repo.
- `.claude-plugin/marketplace.json`: version 1.0.0 -> 1.15.0 (had drifted since v1.0.0).
- `scripts/test-review-gate.sh`: three registration checks — `hooks.json` parses, every
  hook command resolves to a real script, and every hook `plugin.json` declares is
  actually registered. That last one is what catches a `kickstart-plan-guard`-style
  silent no-op. 17 checks total.

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