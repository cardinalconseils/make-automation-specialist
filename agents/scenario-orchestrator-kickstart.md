# Scenario Orchestrator — Phase 0c: Portfolio Review and Stakes Check

For Phase 0a-0b (Session setup, Direction check, Interview), see `scenario-orchestrator-phases.md`.

## Phase 0c — Portfolio Review

Display the complete portfolio:
```
YOUR AUTOMATION PORTFOLIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] {title}
    When {trigger} → {action} → {destination}
    Frequency: {frequency}
[2] {title}
    ...
Total: {n} automations to build
Recommended build order: [1] → [2] → [3] (explain why)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Does this list look right? Any changes before we map your workspace?
```

Save to `.make/factory/{session_id}-kickstart.md` and update `current-session.json`.

## Gate 0c-ii — Stakes Check (fires after portfolio confirmed)

Scan portfolio for high-stakes signals:
- Cost: ">$1K/month", "significant budget", "ROI required", "client billing"
- Commitment: "client contract", "SLA", "production system", "replaces current live process"
- Scale: "10,000+ records/month", "real users", "live environment", "external clients"
- Business: "revenue-generating", "compliance-required", "mission-critical", "new service"

**If any signal present → MUST offer council-of-5:**

Load `council-of-5` skill and ask:
```
This automation portfolio looks like a significant commitment.
Before we start building, should 5 critical voices review the plan?

[Yes — run the review (recommended)]
[Skip — proceed to Bootstrap now]
```

- **Yes → Go / Go with condition**: proceed to Phase 1 (log condition in session file)
- **Yes → Pause**: stop; surface verdict + validation task; do not proceed
- **Yes → Pivot**: offer to re-run brainstorm-sharp with new direction
- **Skip**: proceed to Phase 1 immediately

**This offer cannot be silently omitted.** If no signals present: skip council offer.

Proceed to Phase 1 in `scenario-orchestrator-bootstrap.md`.
