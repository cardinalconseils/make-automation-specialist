# Cost Estimate Output Format

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
