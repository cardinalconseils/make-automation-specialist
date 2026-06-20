# Architecture — Make.com Automation Specialist

## How Claude behaves

1. **Always asks before doing anything.** Full plan shown — modules, cost estimate, docs links — before touching Make.com.
2. **Everything explained simply.** No jargon. Business language throughout.
3. **Guardrails always included.** Every automation gets error handling, observability, and retry logic.
4. **If something breaks,** Claude tries to fix it. If it can't, it logs the error and sends a Telegram message.

---

## Where Claude saves its work

Everything goes into `.make/` inside your project:

```
.make/
  plans/       ← Automation plans waiting for approval
  logs/        ← Execution history with timestamps and costs
  scenarios/   ← Saved scenario blueprints
  changelog/   ← Record of every change Claude made
  audits/      ← Audit reports from /audit runs
  compliance/  ← Compliance scan results
  diagrams/    ← Mermaid flowcharts
  memory/      ← Persistent session memory
  research/    ← Integration research notes
```

---

## Plugin structure

```
plugin.json              ← Plugin manifest (version bumped by scripts/bump-version.sh)
CHANGELOG.md             ← Full release history (read by /make:migrate)
agents/
  automation-specialist  ← Main agent (conversation → plan → build)
  scenario-orchestrator  ← Portfolio factory (Kickstart → Sprint)
  scenario-auditor       ← Audit + fix existing scenarios
  automation-planner     ← Plan generation only, never executes
  scenario-reporter      ← Diagrams and reports (read-only)
  ai-agent-builder       ← Design AI agents inside Make.com
  failure-diagnostician  ← Taxonomy-first error diagnosis
  taxonomy-curator       ← Maintain and extend the failure taxonomy
  telnyx-agent           ← Telnyx communications specialist
  deep-researcher        ← Pre-build integration research
skills/
  failure-diagnostician  ← Loaded by all agents on error paths
  failure-patterns       ← PATTERN-001..008 cross-cutting checks
  blueprint-review       ← 7-point pre-push checklist
  error-handler          ← 5 Make error directives + 8-point audit
  taxonomy-updater       ← Add new patterns to the taxonomy
  formula-expert         ← Make formula syntax reference
  compliance-scanner     ← GDPR, Quebec Law 25, PCI-DSS, HIPAA
  cost-estimator         ← Operation counts and API cost estimates
  diagram-generator      ← Mermaid flowchart builder
  (+ 15 more skills)
hooks/
  on-project-open        ← Auto-runs on session start, maps workspace
  pre-execute            ← Approval gate — nothing executes without OK
  post-execute           ← Logs results, sends alerts on failure
  on-error               ← Auto-recovery attempt + Telegram alert
  on-error-classify      ← Prepends taxonomy code to context on error
  on-sms-voice-context   ← Routes SMS/voice keywords to telnyx-agent
  on-pre-compact         ← Saves workspace snapshot before compaction
taxonomy/
  make-failure-taxonomy.md ← 80+ patterns, 12 categories, authoritative
```
