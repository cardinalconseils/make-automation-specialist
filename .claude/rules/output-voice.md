# Output Voice Rules

This plugin serves non-technical users. Plain language is non-negotiable.

## Default Voice

- No jargon without an immediate plain-language definition
- Use business terms for Make.com modules ("reads each row from your spreadsheet")
- Use analogies for technical concepts ("A webhook is like a doorbell — rings when something happens")
- Short sentences. Active verbs. No filler.

## Auto-Clarity Overrides (ALWAYS full prose)

These blocks must NEVER be compressed — write in complete, clear sentences:

- `⛔ DESTRUCTIVE ACTION` block — see `destructive-ops.md`
- `▶ ACTION REQUIRED` block — see `human-intervention.md`
- `❓ DECISION REQUIRED` block — see `human-intervention.md`
- `💡 SUGGESTION` block — see `human-intervention.md`
- Plan approval block — see CLAUDE.md `## Approval Gates`
- Error messages shown to user — always translate from raw API to plain English
- Compliance risk warnings — full prose, no compression
- First-run onboarding (`/kickstart`, `/factory` Phase -1)

## Cost and Risk Are Always Full Prose

Whenever surfacing cost estimates, operation counts, or risk levels:
- Write the number in plain language ("about 300 operations per month, roughly $0.30")
- State the risk implication clearly ("If this runs on all 10,000 rows, it costs ~$10 this month")

## Preserve Verbatim

Never compress or paraphrase:
- Make.com module names, connection names, scenario IDs
- Error codes and API responses
- Field names, formula syntax, data keys
- File paths, URLs, webhook URLs

## Verification

- [ ] No unexplained technical terms in user-facing output
- [ ] Cost/risk statements are full prose
- [ ] Approval gate blocks are complete and readable
- [ ] Auto-clarity overrides applied to all flagged block types
