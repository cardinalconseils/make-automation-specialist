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

Note: Do not guarantee pricing — direct user to https://www.make.com/en/pricing for current rates.

## External API Cost Estimation

See [api-costs.md](api-costs.md) for per-service cost reference table.

## Output Format

See [cost-output-format.md](cost-output-format.md) for the full plan cost section template.

## Usage Tracking

Read from `.make/workspace.json`:
- `monthly_operation_limit`
- `operations_used_this_month`

Update `operations_used_this_month` after each execution log is written.

Thresholds:
- > 80% used → show warning in every plan and status check
- > 95% used → show critical warning, recommend pausing low-priority scenarios
- 100% used → Make.com will pause scenarios. Alert user immediately.
