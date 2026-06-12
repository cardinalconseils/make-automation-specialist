---
name: cost-estimator
description: Estimates Make.com operation counts and monthly costs for automation plans. Tracks actual usage against plan limits and warns when approaching thresholds.
---

# Skill: cost-estimator

Estimates Make.com operation counts and monetary costs for automation plans.
Also tracks actual usage against plan limits.

## Operation Count Formula

Make.com charges one operation per module execution.

```
operations_per_run = number of modules that execute per scenario run
                     (count active modules, not error-path modules)

monthly_operations = operations_per_run × estimated_runs_per_month
```

### Execution Frequency Estimates

| Trigger type | Estimated runs/month |
|-------------|---------------------|
| Manual only | 10-50 |
| Schedule: once/day | 30 |
| Schedule: 4x/day | 120 |
| Schedule: hourly | 720 |
| Schedule: 15-minute | 2,880 |
| Webhook: low volume (<10/day) | 300 |
| Webhook: medium volume (10-100/day) | 3,000 |
| Webhook: high volume (>100/day) | 30,000+ |
| Watch trigger: polling | estimate based on poll interval |

Ask user for expected volume when trigger is webhook or watch and they haven't specified.

## Make.com Plan Tiers (Reference)

| Plan | Monthly operations | Monthly cost (USD) |
|------|-------------------|-------------------|
| Free | 1,000 | $0 |
| Core | 10,000 | ~$9 |
| Pro | 10,000 + extras | ~$16 |
| Teams | 10,000 + extras | ~$29/user |
| Enterprise | Custom | Custom |

Note: Additional operation bundles available. Do not guarantee pricing — direct user
to https://www.make.com/en/pricing for current rates.

## External API Cost Estimation

For scenarios using AI or paid APIs, estimate per-run cost:

| Service | Unit | Estimated cost |
|---------|------|---------------|
| OpenAI GPT-4o | per 1k tokens | ~$0.005 |
| OpenAI GPT-4o-mini | per 1k tokens | ~$0.0002 |
| Anthropic Claude Sonnet | per 1k tokens | ~$0.003 |
| SendGrid email | per email | ~$0.001 |
| Twilio SMS | per SMS | ~$0.0079 |
| Google Maps geocode | per call | ~$0.005 |

Always caveat: "Prices are estimates based on public rates as of mid-2026. Verify current
pricing on the service provider's website."

## Output Format

Include in every AutomationPlan:

```markdown
## Cost Estimate

### Make.com Operations
| Item | Count |
|------|-------|
| Modules per run | {n} |
| Estimated runs/month | {n} |
| **Total operations/month** | **{n}** |

### Monthly Cost Breakdown
| Item | Cost |
|------|------|
| Make.com operations | ${estimate} |
| OpenAI API (if used) | ${estimate} |
| Other APIs | ${estimate} |
| **Total estimated/month** | **${total}** |

### Plan Usage Impact
| | Before | After |
|-|--------|-------|
| Operations used | {current} | {current + new} |
| Plan limit | {limit} | {limit} |
| Usage % | {before%} | {after%} |

{Warning if after% > 80%: "This automation will push your monthly usage to X%. 
Consider upgrading your plan or reducing polling frequency."}
```

## Usage Tracking

Read from `.make/workspace.json`:
- `monthly_operation_limit`
- `operations_used_this_month`

Update `operations_used_this_month` after each execution log is written.

Thresholds:
- > 80% used → show warning in every plan and status check
- > 95% used → show critical warning, recommend pausing low-priority scenarios
- 100% used → Make.com will pause scenarios. Alert user immediately.
