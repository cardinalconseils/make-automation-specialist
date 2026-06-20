---
name: sprint-runner
description: Sequential scenario build executor. Iterates through an approved automation portfolio, builds each scenario in Make.com one at a time with narration and per-scenario confirmation, writes logs, and produces a factory report. Called by scenario-orchestrator during the Sprint phase.
---

# Skill: sprint-runner

Executes an approved automation portfolio sequentially. Called by scenario-orchestrator
after the user has approved the full batch design. This skill owns the Make.com write
operations — all prior phases are read-only.

## Sub-files

- `SPRINT-PHASES.md` — Input contract, opening announcement, error handling protocol, user controls
- `SPRINT-BUILD.md` — Per-automation build sequence and completion report format

## Deterministic Classification — This Skill Owns Writes

This skill is the ONLY place in the `/factory` pipeline where non-deterministic calls
are made. It runs ONLY during `status: "sprint"` in the factory session.

**Deterministic (call freely):**
```
mcp__claude_ai_Make__scenarios_get
mcp__claude_ai_Make__scenarios_list
mcp__claude_ai_Make__connections_list
mcp__claude_ai_Make__hooks_get
```

**Non-deterministic Level 1 (pre-execute hook gates these):**
```
mcp__claude_ai_Make__scenarios_create
mcp__claude_ai_Make__scenarios_activate
mcp__claude_ai_Make__scenarios_update
mcp__claude_ai_Make__hooks_create
```

**Non-deterministic Level 2 (HIGH RISK — never called automatically):**
```
mcp__claude_ai_Make__scenarios_run    ← only if user explicitly asks to test-run
```

**Non-deterministic Level 3 — PROHIBITED in this skill entirely:**
```
All *_delete tools
```

If `current-session.json` status is anything other than `"sprint"`, this skill
must refuse non-deterministic calls and return control to the orchestrator.

## Output Contract

Returns to orchestrator:
```json
{
  "built": [...],
  "skipped": [...],
  "failed": [...],
  "total_ops_added": 0,
  "report_path": ".make/factory/{session_id}-report.md"
}
```
