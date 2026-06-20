# Intake: Project Artifact Generation

Part of `kickstart-intake`. See `SKILL.md` for execution order.
All artifacts are file writes only — no MCP calls. Deterministic classification preserved.

Sub-files:
- `INTAKE-ARTIFACTS-1.md` — context.md, prd.md
- `INTAKE-ARTIFACTS-2.md` — erd.md, system-design.md
- `INTAKE-ARTIFACTS-3.md` — stack.md, ai-agents.md, generation summary

---

## Execution Order

1. Generate artifacts 1-2 → see `INTAKE-ARTIFACTS-1.md`
2. Generate artifacts 3-4 → see `INTAKE-ARTIFACTS-2.md`
3. Generate artifacts 5-6 → see `INTAKE-ARTIFACTS-3.md`
4. Show artifact generation summary (in `INTAKE-ARTIFACTS-3.md`) to user
5. Update `current-session.json` → `artifacts_generated: true`

---

## File Paths

| Artifact | Path |
|----------|------|
| context.md | `.make/context/context.md` |
| prd.md | `.make/prd.md` |
| erd.md | `.make/context/erd.md` |
| system-design.md | `.make/context/system-design.md` |
| stack.md | `.make/context/stack.md` |
| ai-agents.md | `.make/context/ai-agents.md` (conditional) |

Always use absolute paths when writing to `.make/`.
