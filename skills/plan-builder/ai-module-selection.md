# AI Module Selection Rules

## Detection

Before selecting modules, check if the automation requires AI:
- Is there an `ai_required: true` flag in the input?
- Does the business requirement contain AI signal phrases?
- Is there an AI Agent Blueprint from `ai-agent-designer`?

## If AI Is Required

1. Load the AI Agent Blueprint from `ai-agent-designer` output (or call the skill now)
2. Load the pattern from `agent-pattern-library`
3. Look up exact module specs via `ai-docs-researcher`
4. Incorporate the AI steps into the module sequence
5. Add AI token cost to the cost estimate (in addition to Make.com operations)

## AI-Specific Module Selection Hierarchy (for AI steps only)

1. **Native Make.com AI module** — check for Anthropic, OpenAI, Google AI modules first
2. **OpenAI-compatible HTTP call** — if provider has no native module but is OpenAI-compatible
3. **HTTP module with custom auth** — absolute last resort, document clearly

For the AI module, always call `ai-docs-researcher` before writing the blueprint.
Never guess model IDs or field names for AI modules.
