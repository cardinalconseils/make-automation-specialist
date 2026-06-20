# workspace.json Schema

Write to `.make/workspace.json` after discovery:

```json
{
  "workspace_id": "{make_team_id}",
  "name": "{team_name}",
  "region": "{region}",
  "plan_tier": "{core|pro|teams|enterprise}",
  "monthly_operation_limit": 10000,
  "operations_used_this_month": 2341,
  "scenarios": [
    {
      "id": "123",
      "name": "Lead Intake",
      "status": "active",
      "module_count": 8,
      "last_run_at": "2026-06-09T14:30:00Z"
    }
  ],
  "available_mcps": ["make", "telnyx"],
  "alerts_enabled": true,
  "discovered_at": "{timestamp}",
  "last_refreshed_at": "{timestamp}"
}
```
